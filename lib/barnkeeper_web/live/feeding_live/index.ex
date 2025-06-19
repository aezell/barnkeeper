defmodule BarnkeeperWeb.FeedingLive.Index do
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Care, Teams}

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
       |> stream(:feedings, Care.list_feedings(team.id))}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    feeding = Care.get_feeding!(socket.assigns.team.id, id)

    socket
    |> assign(:page_title, "Edit Feeding")
    |> assign(:feeding, feeding)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Feeding")
    |> assign(:feeding, %Care.Feeding{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Feedings")
    |> assign(:feeding, nil)
  end

  @impl true
  def handle_info({BarnkeeperWeb.FeedingLive.FormComponent, {:saved, feeding}}, socket) do
    {:noreply, stream_insert(socket, :feedings, feeding)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    feeding = Care.get_feeding!(socket.assigns.team.id, id)
    {:ok, _} = Care.delete_feeding(feeding)

    {:noreply, stream_delete(socket, :feedings, feeding)}
  end

  defp format_feed_type(feed_type) do
    feed_type
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
