defmodule BarnkeeperWeb.HorseLive.Index do
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Horses, Teams}
  alias Barnkeeper.Horses.Horse

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
      horses = Horses.list_horses(team.id)

      {:ok,
       socket
       |> assign(:team, team)
       |> stream(:horses, horses)
       |> assign(:horses_count, length(horses))
       |> assign(:page_title, "Horses")}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    horse = Horses.get_horse!(socket.assigns.team.id, id)

    socket
    |> assign(:page_title, "Edit Horse")
    |> assign(:horse, horse)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Horse")
    |> assign(:horse, %Horse{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Horses")
    |> assign(:horse, nil)
  end

  @impl true
  def handle_info({BarnkeeperWeb.HorseLive.FormComponent, {:saved, horse}}, socket) do
    {:noreply,
     socket
     |> stream_insert(:horses, horse)
     |> assign(:horses_count, socket.assigns.horses_count + 1)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    horse = Horses.get_horse!(socket.assigns.team.id, id)
    {:ok, _} = Horses.delete_horse(socket.assigns.team.id, horse)

    {:noreply,
     socket
     |> stream_delete(:horses, horse)
     |> assign(:horses_count, socket.assigns.horses_count - 1)}
  end
end
