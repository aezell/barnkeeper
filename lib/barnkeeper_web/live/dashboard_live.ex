defmodule BarnkeeperWeb.DashboardLive do
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Horses, Teams}

  @impl true
  def mount(_params, _session, socket) do
    # For now, we'll need to handle team selection logic later
    # This is a simplified version assuming user has a team
    user = socket.assigns.current_user

    # TODO: Implement proper team selection
    # For now, get first team the user belongs to
    memberships = Teams.list_user_memberships(user.id)

    team =
      case memberships do
        [membership | _] -> membership.team
        [] -> nil
      end

    if team do
      horses = Horses.list_horses(team.id)

      socket =
        socket
        |> assign(:team, team)
        |> assign(:horses, horses)
        |> assign(:horse_count, length(horses))
        # TODO: Add recent activities
        |> assign(:recent_activities, [])
        |> assign(:page_title, "Dashboard")

      {:ok, socket}
    else
      # User has no team, redirect to team setup
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
