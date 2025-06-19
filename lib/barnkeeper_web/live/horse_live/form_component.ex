defmodule BarnkeeperWeb.HorseLive.FormComponent do
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Horses

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage horse records.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="horse-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" required />
        <.input field={@form[:breed]} type="text" label="Breed" />
        <.input field={@form[:color]} type="text" label="Color" />
        <.input
          field={@form[:gender]}
          type="select"
          label="Gender"
          options={[
            {"Mare", "mare"},
            {"Stallion", "stallion"},
            {"Gelding", "gelding"},
            {"Filly", "filly"},
            {"Colt", "colt"}
          ]}
        />
        <.input field={@form[:birth_date]} type="date" label="Birth Date" />
        <.input
          field={@form[:size]}
          type="select"
          label="Size"
          options={[
            {"Pony", "pony"},
            {"Horse", "horse"},
            {"Draft", "draft"}
          ]}
        />
        <.input field={@form[:registration_number]} type="text" label="Registration Number" />
        <.input field={@form[:microchip_number]} type="text" label="Microchip Number" />
        <.input field={@form[:passport_number]} type="text" label="Passport Number" />
        <.input field={@form[:insurance_policy]} type="text" label="Insurance Policy" />
        <.input field={@form[:insurance_company]} type="text" label="Insurance Company" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Horse</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{horse: horse} = assigns, socket) do
    changeset = Horses.change_horse(horse)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"horse" => horse_params}, socket) do
    changeset =
      socket.assigns.horse
      |> Horses.change_horse(horse_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"horse" => horse_params}, socket) do
    save_horse(socket, socket.assigns.action, horse_params)
  end

  defp save_horse(socket, :edit, horse_params) do
    case Horses.update_horse(socket.assigns.team_id, socket.assigns.horse, horse_params) do
      {:ok, horse} ->
        notify_parent({:saved, horse})

        {:noreply,
         socket
         |> put_flash(:info, "Horse updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_horse(socket, :new, horse_params) do
    case Horses.create_horse(socket.assigns.team_id, horse_params) do
      {:ok, horse} ->
        notify_parent({:saved, horse})

        {:noreply,
         socket
         |> put_flash(:info, "Horse created successfully")
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
