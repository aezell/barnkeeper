defmodule BarnkeeperWeb.NoteLive.FormComponent do
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Notes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage horse notes.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="note-form"
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

        <.input field={@form[:title]} type="text" label="Title" required />

        <.input
          field={@form[:note_type]}
          type="select"
          label="Note Type"
          options={[
            {"General", "general"},
            {"Medical", "medical"},
            {"Training", "training"},
            {"Behavior", "behavior"},
            {"Feeding", "feeding"},
            {"Other", "other"}
          ]}
          prompt="Select note type"
          required
        />

        <.input field={@form[:content]} type="textarea" label="Content" rows="6" required />

        <:actions>
          <.button phx-disable-with="Saving...">Save Note</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{note: note} = assigns, socket) do
    changeset = Notes.change_note(note)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"note" => note_params}, socket) do
    changeset =
      socket.assigns.note
      |> Notes.change_note(note_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"note" => note_params}, socket) do
    save_note(socket, socket.assigns.action, note_params)
  end

  defp save_note(socket, :edit, note_params) do
    case Notes.update_note(socket.assigns.note, note_params) do
      {:ok, note} ->
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_flash(:info, "Note updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_note(socket, :new, note_params) do
    # Add current user as recorded_by
    note_params = Map.put(note_params, "recorded_by_id", socket.assigns.current_user_id)

    case Notes.create_note(note_params) do
      {:ok, note} ->
        # Preload associations for the stream
        note = Notes.get_note!(socket.assigns.team_id, note.id)
        notify_parent({:saved, note})

        {:noreply,
         socket
         |> put_flash(:info, "Note created successfully")
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
