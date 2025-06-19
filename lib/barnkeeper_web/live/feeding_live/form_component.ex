defmodule BarnkeeperWeb.FeedingLive.FormComponent do
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Care

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage feeding records.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="feeding-form"
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
          field={@form[:feed_type]}
          type="select"
          label="Feed Type"
          options={[
            {"Hay", "hay"},
            {"Grain", "grain"},
            {"Pellets", "pellets"},
            {"Supplements", "supplements"},
            {"Treats", "treats"},
            {"Other", "other"}
          ]}
          prompt="Select feed type"
          required
        />

        <.input field={@form[:feed_name]} type="text" label="Feed Name" required />

        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:amount]} type="number" label="Amount" step="0.1" min="0" required />

          <.input
            field={@form[:unit]}
            type="select"
            label="Unit"
            options={[
              {"Pounds", "lbs"},
              {"Cups", "cups"},
              {"Scoops", "scoops"},
              {"Flakes", "flakes"},
              {"Bales", "bales"},
              {"Other", "other"}
            ]}
            prompt="Select unit"
            required
          />
        </div>

        <.input field={@form[:feeding_time]} type="datetime-local" label="Feeding Time" required />

        <.input field={@form[:notes]} type="textarea" label="Notes" rows="3" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Feeding</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{feeding: feeding} = assigns, socket) do
    changeset = Care.change_feeding(feeding)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"feeding" => feeding_params}, socket) do
    changeset =
      socket.assigns.feeding
      |> Care.change_feeding(feeding_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"feeding" => feeding_params}, socket) do
    save_feeding(socket, socket.assigns.action, feeding_params)
  end

  defp save_feeding(socket, :edit, feeding_params) do
    case Care.update_feeding(socket.assigns.feeding, feeding_params) do
      {:ok, feeding} ->
        notify_parent({:saved, feeding})

        {:noreply,
         socket
         |> put_flash(:info, "Feeding updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_feeding(socket, :new, feeding_params) do
    # Add current user as fed_by
    feeding_params = Map.put(feeding_params, "fed_by_id", socket.assigns.current_user_id)

    case Care.create_feeding(feeding_params) do
      {:ok, feeding} ->
        # Preload associations for the stream
        feeding = Care.get_feeding!(socket.assigns.team_id, feeding.id)
        notify_parent({:saved, feeding})

        {:noreply,
         socket
         |> put_flash(:info, "Feeding created successfully")
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
