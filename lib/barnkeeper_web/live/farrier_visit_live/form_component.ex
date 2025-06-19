defmodule BarnkeeperWeb.FarrierVisitLive.FormComponent do
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Care

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage farrier visit records.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="farrier-visit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:horse_id]}
          type="select"
          label="Horse"
          options={Enum.map(@horses, &{&1.name, &1.id})}
          prompt="Select a horse"
          required
        />

        <.input
          field={@form[:work_type]}
          type="select"
          label="Work Type"
          options={[
            {"Shoeing", "shoeing"},
            {"Trimming", "trimming"},
            {"Corrective", "corrective"},
            {"Therapeutic", "therapeutic"},
            {"Other", "other"}
          ]}
          prompt="Select work type"
          required
        />

        <.input field={@form[:visit_date]} type="date" label="Visit Date" required />

        <.input field={@form[:farrier_name]} type="text" label="Farrier Name" required />

        <.input field={@form[:farrier_phone]} type="text" label="Farrier Phone" />

        <.input field={@form[:work_performed]} type="textarea" label="Work Performed" rows="3" />

        <.input field={@form[:next_visit_date]} type="date" label="Next Visit Date" />

        <.input field={@form[:cost]} type="number" label="Cost ($)" step="0.01" min="0" />

        <.input field={@form[:notes]} type="textarea" label="Notes" rows="4" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Farrier Visit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{farrier_visit: farrier_visit} = assigns, socket) do
    changeset = Care.change_farrier_visit(farrier_visit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"farrier_visit" => farrier_visit_params}, socket) do
    changeset =
      socket.assigns.farrier_visit
      |> Care.change_farrier_visit(farrier_visit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"farrier_visit" => farrier_visit_params}, socket) do
    save_farrier_visit(socket, socket.assigns.action, farrier_visit_params)
  end

  defp save_farrier_visit(socket, :edit, farrier_visit_params) do
    case Care.update_farrier_visit(socket.assigns.farrier_visit, farrier_visit_params) do
      {:ok, farrier_visit} ->
        notify_parent({:saved, farrier_visit})

        {:noreply,
         socket
         |> put_flash(:info, "Farrier visit updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_farrier_visit(socket, :new, farrier_visit_params) do
    # Add current user as recorded_by
    farrier_visit_params =
      Map.put(farrier_visit_params, "recorded_by_id", socket.assigns.current_user_id)

    case Care.create_farrier_visit(farrier_visit_params) do
      {:ok, farrier_visit} ->
        # Preload associations for the stream
        farrier_visit = Care.get_farrier_visit!(socket.assigns.team_id, farrier_visit.id)
        notify_parent({:saved, farrier_visit})

        {:noreply,
         socket
         |> put_flash(:info, "Farrier visit created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
