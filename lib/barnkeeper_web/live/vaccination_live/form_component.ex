defmodule BarnkeeperWeb.VaccinationLive.FormComponent do
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Care

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage vaccination records.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="vaccination-form"
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
          field={@form[:vaccine_name]}
          type="text"
          label="Vaccine Name"
          placeholder="e.g., Tetanus, Flu/Rhino, EEE/WEE"
          required
        />

        <.input field={@form[:vaccination_date]} type="date" label="Vaccination Date" required />

        <.input field={@form[:veterinarian_name]} type="text" label="Veterinarian Name" required />

        <.input field={@form[:veterinarian_phone]} type="text" label="Veterinarian Phone" />

        <.input
          field={@form[:batch_number]}
          type="text"
          label="Batch Number"
          placeholder="Vaccine batch/lot number"
        />

        <.input field={@form[:expiration_date]} type="date" label="Expiration Date" />

        <.input field={@form[:next_due_date]} type="date" label="Next Due Date" />

        <.input field={@form[:cost]} type="number" label="Cost ($)" step="0.01" min="0" />

        <.input
          field={@form[:notes]}
          type="textarea"
          label="Notes"
          rows="4"
          placeholder="Additional notes about the vaccination"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Vaccination</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{vaccination: vaccination} = assigns, socket) do
    changeset = Care.change_vaccination(vaccination)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"vaccination" => vaccination_params}, socket) do
    changeset =
      socket.assigns.vaccination
      |> Care.change_vaccination(vaccination_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"vaccination" => vaccination_params}, socket) do
    save_vaccination(socket, socket.assigns.action, vaccination_params)
  end

  defp save_vaccination(socket, :edit, vaccination_params) do
    case Care.update_vaccination(socket.assigns.vaccination, vaccination_params) do
      {:ok, vaccination} ->
        notify_parent({:saved, vaccination})

        {:noreply,
         socket
         |> put_flash(:info, "Vaccination updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_vaccination(socket, :new, vaccination_params) do
    # Add current user as recorded_by
    vaccination_params =
      Map.put(vaccination_params, "recorded_by_id", socket.assigns.current_user_id)

    case Care.create_vaccination(vaccination_params) do
      {:ok, vaccination} ->
        # Preload associations for the stream
        vaccination = Care.get_vaccination!(socket.assigns.team_id, vaccination.id)
        notify_parent({:saved, vaccination})

        {:noreply,
         socket
         |> put_flash(:info, "Vaccination created successfully")
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
