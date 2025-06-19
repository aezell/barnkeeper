defmodule BarnkeeperWeb.VaccinationLive.Show do
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
    vaccination = Care.get_vaccination!(socket.assigns.team.id, id)
    horses = Horses.list_horses(socket.assigns.team.id)

    {:noreply,
     socket
     |> assign(:page_title, "Vaccination Details")
     |> assign(:vaccination, vaccination)
     |> assign(:horses, horses)}
  end

  @impl true
  def handle_info({BarnkeeperWeb.VaccinationLive.FormComponent, {:saved, vaccination}}, socket) do
    {:noreply, assign(socket, :vaccination, vaccination)}
  end
end
