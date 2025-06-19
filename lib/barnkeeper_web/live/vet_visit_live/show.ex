defmodule BarnkeeperWeb.VetVisitLive.Show do
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
    vet_visit = Care.get_vet_visit!(socket.assigns.team.id, id)
    horses = Horses.list_horses(socket.assigns.team.id)

    {:noreply,
     socket
     |> assign(:page_title, "Vet Visit Details")
     |> assign(:vet_visit, vet_visit)
     |> assign(:horses, horses)}
  end

  @impl true
  def handle_info({BarnkeeperWeb.VetVisitLive.FormComponent, {:saved, vet_visit}}, socket) do
    {:noreply, assign(socket, :vet_visit, vet_visit)}
  end

  defp format_visit_type(visit_type) do
    visit_type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.upcase()
  end
end
