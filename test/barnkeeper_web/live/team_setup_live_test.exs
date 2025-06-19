defmodule BarnkeeperWeb.TeamSetupLiveTest do
  use BarnkeeperWeb.ConnCase

  import Phoenix.LiveViewTest
  import Barnkeeper.AccountsFixtures

  describe "Team Setup" do
    test "renders team setup page for user without team", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, _view, html} = live(conn, ~p"/team/setup")

      assert html =~ "Setup Your Team"
      assert html =~ "Create a new barn or farm team"
      assert html =~ "Team Name"
      assert html =~ "Description"
      assert html =~ "City"
      assert html =~ "State"
      assert html =~ "Phone"
      assert html =~ "Email"
    end

    test "redirects to dashboard if user already has a team", %{conn: conn} do
      user = user_fixture()

      # Create a team with the user as admin
      {:ok, %{team: _team, membership: _membership}} =
        Barnkeeper.Teams.create_team_with_admin(
          %{
            name: "Test Barn",
            description: "A test barn"
          },
          user
        )

      conn = log_in_user(conn, user)

      # Should redirect to dashboard since user already has a team
      assert {:error, {:live_redirect, %{to: "/dashboard", flash: %{}}}} =
               live(conn, ~p"/team/setup")
    end

    test "validates team form on change", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/team/setup")

      # Test validation with empty name
      html =
        view
        |> form("#team-form", team: %{name: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "creates team successfully with valid data", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/team/setup")

      team_params = %{
        name: "Sunset Stables",
        description: "A beautiful riding facility",
        city: "Austin",
        state: "TX",
        phone: "555-0123",
        email: "info@sunsetstables.com"
      }

      # Submit the form
      view
      |> form("#team-form", team: team_params)
      |> render_submit()

      # Should redirect to dashboard
      assert_redirected(view, ~p"/dashboard")

      # Verify team was created
      memberships = Barnkeeper.Teams.list_user_memberships(user.id)
      assert length(memberships) == 1

      team = List.first(memberships).team
      assert team.name == "Sunset Stables"
      assert team.description == "A beautiful riding facility"
      assert team.city == "Austin"
      assert team.state == "TX"
    end

    test "shows error when team creation fails", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/team/setup")

      # Submit form with invalid data (empty name)
      html =
        view
        |> form("#team-form", team: %{name: ""})
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end

    test "form renders without protocol errors", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      # This test specifically ensures the form renders without Phoenix.HTML.Safe protocol errors
      assert {:ok, _view, html} = live(conn, ~p"/team/setup")

      # The form should render successfully
      assert html =~ "team-form"
      assert html =~ "phx-submit=\"save_team\""
      assert html =~ "phx-change=\"validate\""

      # Should not contain any protocol error messages
      refute html =~ "Protocol.UndefinedError"
      refute html =~ "Phoenix.HTML.Safe not implemented"
    end
  end
end
