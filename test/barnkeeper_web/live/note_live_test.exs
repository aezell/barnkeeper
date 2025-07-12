defmodule BarnkeeperWeb.NoteLiveTest do
  use BarnkeeperWeb.ConnCase

  import Phoenix.LiveViewTest
  import Barnkeeper.{TeamsFixtures, HorsesFixtures, NotesFixtures}

  @create_attrs %{
    "title" => "Test Note",
    "content" => "This is test content",
    "is_private" => false
  }
  @update_attrs %{
    "title" => "Updated Note",
    "content" => "Updated content",
    "is_private" => true
  }
  @invalid_attrs %{"title" => "", "content" => ""}

  defp create_note(%{user: user, horse: horse}) do
    note = note_fixture(horse, user)
    %{note: note}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_team_and_horse]

    test "lists all notes", %{conn: conn, user: user, horse: horse} do
      note = note_fixture(horse, user)
      {:ok, _index_live, html} = live(conn, ~p"/notes")

      assert html =~ "Notes"
      assert html =~ note.title
    end

    test "filters notes by horse_id when provided", %{
      conn: conn,
      user: user,
      team: team,
      horse: horse
    } do
      note = note_fixture(horse, user)
      horse2 = horse_fixture(team, %{"name" => "Second Horse"})
      _note2 = note_fixture(horse2, user, %{"title" => "Second Note"})

      {:ok, _index_live, html} = live(conn, ~p"/notes?horse_id=#{horse.id}")

      assert html =~ "Notes for #{horse.name}"
      assert html =~ note.title
      refute html =~ "Second Note"
    end

    test "saves new note", %{conn: conn, horse: horse} do
      {:ok, index_live, _html} = live(conn, ~p"/notes")

      assert index_live |> element("a", "New Note") |> render_click() =~
               "New Note"

      assert_patch(index_live, ~p"/notes/new")

      assert index_live
             |> form("#note-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#note-form", note: Map.put(@create_attrs, "horse_id", horse.id))
             |> render_submit()

      assert_patch(index_live, ~p"/notes")

      html = render(index_live)
      assert html =~ "Note created successfully"
      assert html =~ "Test Note"
    end

    test "saves new note with horse_id pre-populated", %{conn: conn, horse: horse} do
      {:ok, index_live, _html} = live(conn, ~p"/notes?horse_id=#{horse.id}")

      assert index_live |> element("a", "New Note") |> render_click() =~
               "New Note"

      assert_patch(index_live, ~p"/notes/new?horse_id=#{horse.id}")

      # The horse should be pre-selected
      assert index_live
             |> form("#note-form", note: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/notes?horse_id=#{horse.id}")

      html = render(index_live)
      assert html =~ "Note created successfully"
      assert html =~ "Test Note"
    end

    test "updates note in listing", %{conn: conn, user: user, horse: horse} do
      note = note_fixture(horse, user)
      {:ok, index_live, _html} = live(conn, ~p"/notes")

      assert index_live |> element("#notes-#{note.id} a", "Edit") |> render_click() =~
               "Edit Note"

      assert_patch(index_live, ~p"/notes/#{note.id}/edit")

      assert index_live
             |> form("#note-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#note-form", note: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/notes")

      html = render(index_live)
      assert html =~ "Note updated successfully"
      assert html =~ "Updated Note"
    end

    test "deletes note in listing", %{conn: conn, user: user, horse: horse} do
      note = note_fixture(horse, user)
      {:ok, index_live, _html} = live(conn, ~p"/notes")

      assert index_live |> element("#notes-#{note.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#notes-#{note.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_team_and_horse, :create_note]

    test "displays note", %{conn: conn, note: note} do
      {:ok, _show_live, html} = live(conn, ~p"/notes/#{note.id}")

      assert html =~ note.title
      assert html =~ note.content
    end

    test "updates note within modal", %{conn: conn, note: note} do
      {:ok, show_live, _html} = live(conn, ~p"/notes/#{note.id}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Note"

      assert_patch(show_live, ~p"/notes/#{note.id}/show/edit")

      assert show_live
             |> form("#note-form", note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#note-form", note: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/notes/#{note.id}")

      html = render(show_live)
      assert html =~ "Note updated successfully"
      assert html =~ "Updated Note"
    end
  end

  defp create_team_and_horse(%{user: user}) do
    team = team_fixture(user)
    horse = horse_fixture(team)
    %{team: team, horse: horse}
  end
end
