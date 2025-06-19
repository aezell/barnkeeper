defmodule BarnkeeperWeb.VetVisitLive.FormComponent do
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Care

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage vet visit records.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="vet-visit-form"
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
          field={@form[:visit_type]}
          type="select"
          label="Visit Type"
          options={[
            {"Routine", "routine"},
            {"Emergency", "emergency"},
            {"Dental", "dental"},
            {"Reproductive", "reproductive"},
            {"Surgery", "surgery"},
            {"Other", "other"}
          ]}
          prompt="Select visit type"
          required
        />

        <.input field={@form[:visit_date]} type="date" label="Visit Date" required />

        <.input field={@form[:veterinarian_name]} type="text" label="Veterinarian Name" required />

        <.input field={@form[:veterinarian_phone]} type="text" label="Veterinarian Phone" />

        <.input field={@form[:diagnosis]} type="textarea" label="Diagnosis" rows="3" />

        <.input field={@form[:treatment]} type="textarea" label="Treatment" rows="3" />

        <.input field={@form[:medications]} type="textarea" label="Medications" rows="3" />

        <.input field={@form[:follow_up_date]} type="date" label="Follow-up Date" />

        <.input field={@form[:cost]} type="number" label="Cost ($)" step="0.01" min="0" />

        <.input field={@form[:notes]} type="textarea" label="Notes" rows="4" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Vet Visit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{vet_visit: vet_visit} = assigns, socket) do
    changeset = Care.change_vet_visit(vet_visit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"vet_visit" => vet_visit_params}, socket) do
    changeset =
      socket.assigns.vet_visit
      |> Care.change_vet_visit(vet_visit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"vet_visit" => vet_visit_params}, socket) do
    save_vet_visit(socket, socket.assigns.action, vet_visit_params)
  end

  defp save_vet_visit(socket, :edit, vet_visit_params) do
    case Care.update_vet_visit(socket.assigns.vet_visit, vet_visit_params) do
      {:ok, vet_visit} ->
        notify_parent({:saved, vet_visit})

        {:noreply,
         socket
         |> put_flash(:info, "Vet visit updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_vet_visit(socket, :new, vet_visit_params) do
    # Add current user as recorded_by
    vet_visit_params = Map.put(vet_visit_params, "recorded_by_id", socket.assigns.current_user_id)

    case Care.create_vet_visit(vet_visit_params) do
      {:ok, vet_visit} ->
        # Preload associations for the stream
        vet_visit = Care.get_vet_visit!(socket.assigns.team_id, vet_visit.id)
        notify_parent({:saved, vet_visit})

        {:noreply,
         socket
         |> put_flash(:info, "Vet visit created successfully")
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
