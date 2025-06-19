defmodule BarnkeeperWeb.TeamSetupLive do
  @moduledoc """
  Team setup LiveView for users who need to create or join a team.
  """
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.Teams

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    # Check if user already has a team
    memberships = Teams.list_user_memberships(user.id)

    if memberships != [] do
      # User already has a team, redirect to dashboard
      {:ok, push_navigate(socket, to: ~p"/dashboard")}
    else
      changeset = Teams.change_team(%Teams.Team{})

      socket =
        socket
        |> assign(:page_title, "Setup Your Team")
        |> assign(:form, to_form(changeset))
        |> assign(:step, :create_team)

      {:ok, socket}
    end
  end

  @impl true
  def handle_event("save_team", %{"team" => team_params}, socket) do
    user = socket.assigns.current_user

    case Teams.create_team_with_admin(team_params, user) do
      {:ok, %{team: _team, membership: _membership}} ->
        socket =
          socket
          |> put_flash(:info, "Team created successfully!")
          |> push_navigate(to: ~p"/dashboard")

        {:noreply, socket}

      {:error, _operation, changeset, _changes} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"team" => team_params}, socket) do
    changeset =
      %Teams.Team{}
      |> Teams.change_team(team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
