defmodule BarnkeeperWeb.FeedingLive.Show do
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Care, Teams, Horses}

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
    feeding = Care.get_feeding!(socket.assigns.team.id, id)
    horses = Horses.list_horses(socket.assigns.team.id)

    {:noreply,
     socket
     |> assign(:page_title, "Feeding Details")
     |> assign(:feeding, feeding)
     |> assign(:horses, horses)}
  end

  @impl true
  def handle_info({BarnkeeperWeb.FeedingLive.FormComponent, {:saved, feeding}}, socket) do
    {:noreply, assign(socket, :feeding, feeding)}
  end

  defp format_feed_type(feed_type) do
    feed_type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.upcase()
  end
end
