defmodule BarnkeeperWeb.VetVisitLive.Index do
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
      {:ok,
       socket
       |> assign(:team, team)
       |> stream(:vet_visits, Care.list_vet_visits(team.id))}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    vet_visit = Care.get_vet_visit!(socket.assigns.team.id, id)

    socket
    |> assign(:page_title, "Edit Vet Visit")
    |> assign(:vet_visit, vet_visit)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Vet Visit")
    |> assign(:vet_visit, %Care.VetVisit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Vet Visits")
    |> assign(:vet_visit, nil)
  end

  @impl true
  def handle_info({BarnkeeperWeb.VetVisitLive.FormComponent, {:saved, vet_visit}}, socket) do
    {:noreply, stream_insert(socket, :vet_visits, vet_visit)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    vet_visit = Care.get_vet_visit!(socket.assigns.team.id, id)
    {:ok, _} = Care.delete_vet_visit(vet_visit)

    {:noreply, stream_delete(socket, :vet_visits, vet_visit)}
  end

  defp format_visit_type(visit_type) do
    visit_type
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
