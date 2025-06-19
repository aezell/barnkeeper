defmodule BarnkeeperWeb.VaccinationLive.Index do
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
      horses = Horses.list_horses(team.id)
      vaccinations = Care.list_vaccinations(team.id)

      {:ok,
       socket
       |> assign(:team, team)
       |> assign(:horses, horses)
       |> assign(:vaccinations_count, Enum.count(vaccinations))
       |> stream(:vaccinations, vaccinations)}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    vaccination = Care.get_vaccination!(socket.assigns.team.id, id)

    socket
    |> assign(:page_title, "Edit Vaccination")
    |> assign(:vaccination, vaccination)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Vaccination")
    |> assign(:vaccination, %Care.Vaccination{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Vaccinations")
    |> assign(:vaccination, nil)
  end

  @impl true
  def handle_info({BarnkeeperWeb.VaccinationLive.FormComponent, {:saved, vaccination}}, socket) do
    {:noreply, stream_insert(socket, :vaccinations, vaccination)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    vaccination = Care.get_vaccination!(socket.assigns.team.id, id)
    {:ok, _} = Care.delete_vaccination(vaccination)

    {:noreply, stream_delete(socket, :vaccinations, vaccination)}
  end
end
