defmodule BarnkeeperWeb.FarrierVisitLive.Show do
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
    farrier_visit = Care.get_farrier_visit!(socket.assigns.team.id, id)
    horses = Horses.list_horses(socket.assigns.team.id)

    {:noreply,
     socket
     |> assign(:page_title, "Farrier Visit Details")
     |> assign(:farrier_visit, farrier_visit)
     |> assign(:horses, horses)}
  end

  @impl true
  def handle_info({BarnkeeperWeb.FarrierVisitLive.FormComponent, {:saved, farrier_visit}}, socket) do
    {:noreply, assign(socket, :farrier_visit, farrier_visit)}
  end

  defp format_work_type(work_type) do
    work_type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.upcase()
  end
end
