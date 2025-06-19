defmodule BarnkeeperWeb.NoteLive.Index do
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Notes, Teams}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    # Get user's team
    memberships = Teams.list_user_memberships(user.id)

    team =
      case memberships do
        [membership | _] -> membership.team
        [] -> nil
      end

    if team do
      horses = Barnkeeper.Horses.list_horses(team.id)

      {:ok,
       socket
       |> assign(:team, team)
       |> assign(:horses, horses)
       |> stream(:notes, Notes.list_notes(team.id))}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    note = Notes.get_note!(socket.assigns.team.id, id)

    socket
    |> assign(:page_title, "Edit Note")
    |> assign(:note, note)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Note")
    |> assign(:note, %Notes.Note{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Notes")
    |> assign(:note, nil)
  end

  @impl true
  def handle_info({BarnkeeperWeb.NoteLive.FormComponent, {:saved, note}}, socket) do
    {:noreply, stream_insert(socket, :notes, note)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    note = Notes.get_note!(socket.assigns.team.id, id)
    {:ok, _} = Notes.delete_note(note)

    {:noreply, stream_delete(socket, :notes, note)}
  end

  defp format_note_type(note_type) do
    note_type
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
