defmodule BarnkeeperWeb.FarrierVisitLive.Index do
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
       |> stream(:farrier_visits, Care.list_farrier_visits(team.id))}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    farrier_visit = Care.get_farrier_visit!(socket.assigns.team.id, id)

    socket
    |> assign(:page_title, "Edit Farrier Visit")
    |> assign(:farrier_visit, farrier_visit)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Farrier Visit")
    |> assign(:farrier_visit, %Care.FarrierVisit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Farrier Visits")
    |> assign(:farrier_visit, nil)
  end

  @impl true
  def handle_info({BarnkeeperWeb.FarrierVisitLive.FormComponent, {:saved, farrier_visit}}, socket) do
    {:noreply, stream_insert(socket, :farrier_visits, farrier_visit)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    farrier_visit = Care.get_farrier_visit!(socket.assigns.team.id, id)
    {:ok, _} = Care.delete_farrier_visit(farrier_visit)

    {:noreply, stream_delete(socket, :farrier_visits, farrier_visit)}
  end

  defp format_visit_type(visit_type) do
    visit_type
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
