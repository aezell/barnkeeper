defmodule BarnkeeperWeb.HorseLiveTest do
  use BarnkeeperWeb.ConnCase

  import Phoenix.LiveViewTest
  import Barnkeeper.{AccountsFixtures, TeamsFixtures, HorsesFixtures}

  @create_attrs %{
    "name" => "Test Horse",
    "breed" => "Thoroughbred",
    "color" => "Bay",
    "birth_date" => "2015-01-01",
    "size" => "horse"
  }
  @update_attrs %{
    "name" => "Updated Horse",
    "breed" => "Quarter Horse",
    "color" => "Chestnut",
    "birth_date" => "2014-01-01",
    "size" => "draft"
  }
  @invalid_attrs %{name: nil, breed: nil, color: nil}

  defp create_horse(_) do
    user = user_fixture()
    team = team_fixture(user)
    horse = horse_fixture(team)
    %{user: user, team: team, horse: horse}
  end

  describe "Index" do
    setup [:create_horse]

    test "lists all horses", %{conn: conn, user: user, horse: horse} do
      {:ok, _index_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/horses")

      assert html =~ "Horses"
      assert html =~ horse.name
    end

    test "saves new horse", %{conn: conn, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/horses")

      assert index_live |> element("a", "New Horse") |> render_click() =~
               "New Horse"

      assert_patch(index_live, ~p"/horses/new")

      assert index_live
             |> form("#horse-form", horse: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#horse-form", horse: @create_attrs)
             |> render_submit() =~ "Horse created successfully"
    end

    test "updates horse in listing", %{conn: conn, user: user, horse: horse} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/horses")

      assert index_live |> element("#horses-#{horse.id} a", "Edit") |> render_click() =~
               "Edit Horse"

      assert_patch(index_live, ~p"/horses/#{horse}/edit")

      assert index_live
             |> form("#horse-form", horse: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#horse-form", horse: @update_attrs)
             |> render_submit() =~ "Horse updated successfully"
    end

    test "deletes horse in listing", %{conn: conn, user: user, horse: horse} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/horses")

      assert index_live |> element("#horses-#{horse.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#horses-#{horse.id}")
    end

    test "handles empty stream without errors", %{conn: conn} do
      # This test specifically ensures @horses_count == 0 works correctly
      user = user_fixture()
      _team = team_fixture(user)

      {:ok, _index_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/horses")

      # The page should render without ArgumentError when checking empty stream
      assert html =~ "No horses yet"
      assert html =~ "Get started by adding your first horse"
      refute html =~ "ArgumentError"
    end
  end
end
