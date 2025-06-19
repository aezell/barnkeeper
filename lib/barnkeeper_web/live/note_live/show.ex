defmodule BarnkeeperWeb.NoteLive.Show do
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Notes, Teams, Horses}

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
      {:ok, assign(socket, :team, team)}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    note = Notes.get_note!(socket.assigns.team.id, id)
    horses = Horses.list_horses(socket.assigns.team.id)

    {:noreply,
     socket
     |> assign(:page_title, "Note Details")
     |> assign(:note, note)
     |> assign(:horses, horses)}
  end

  @impl true
  def handle_info({BarnkeeperWeb.NoteLive.FormComponent, {:saved, note}}, socket) do
    {:noreply, assign(socket, :note, note)}
  end

  defp format_note_type(note_type) do
    note_type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.upcase()
  end
end
