defmodule Barnkeeper.NotesTest do
  use Barnkeeper.DataCase

  import Barnkeeper.{AccountsFixtures, TeamsFixtures, HorsesFixtures, NotesFixtures}

  alias Barnkeeper.Notes

  describe "notes" do
    alias Barnkeeper.Notes.Note

    setup do
      user = user_fixture()
      team = team_fixture(user)
      horse = horse_fixture(team)
      %{user: user, team: team, horse: horse}
    end

    test "list_notes/1 returns all notes for a team", %{user: user, team: team, horse: horse} do
      note = note_fixture(horse, user)
      notes = Notes.list_notes(team.id)
      assert length(notes) == 1
      assert List.first(notes).id == note.id
    end

    test "list_notes/2 returns notes for a specific horse", %{
      user: user,
      team: team,
      horse: horse
    } do
      note = note_fixture(horse, user)
      # Create another horse and note
      horse2 = horse_fixture(team, %{"name" => "Second Horse"})
      _note2 = note_fixture(horse2, user, %{"title" => "Second Note"})

      notes = Notes.list_notes(team.id, horse.id)
      assert length(notes) == 1
      assert List.first(notes).id == note.id
    end

    test "get_note!/2 returns the note with given id", %{user: user, team: team, horse: horse} do
      note = note_fixture(horse, user)
      found_note = Notes.get_note!(team.id, note.id)
      assert found_note.id == note.id
      assert found_note.title == note.title
    end

    test "create_note/1 with valid data creates a note", %{user: user, horse: horse} do
      valid_attrs = %{
        "title" => "Valid Note",
        "content" => "Valid content",
        "is_private" => true,
        "horse_id" => horse.id,
        "author_id" => user.id
      }

      assert {:ok, %Note{} = note} = Notes.create_note(valid_attrs)
      assert note.title == "Valid Note"
      assert note.content == "Valid content"
      assert note.is_private == true
      assert note.horse_id == horse.id
      assert note.author_id == user.id
    end

    test "create_note/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notes.create_note(%{})
    end

    test "update_note/2 with valid data updates the note", %{user: user, horse: horse} do
      note = note_fixture(horse, user)
      update_attrs = %{"title" => "Updated Title", "content" => "Updated content"}

      assert {:ok, %Note{} = note} = Notes.update_note(note, update_attrs)
      assert note.title == "Updated Title"
      assert note.content == "Updated content"
    end

    test "update_note/2 with invalid data returns error changeset", %{
      user: user,
      team: team,
      horse: horse
    } do
      note = note_fixture(horse, user)
      assert {:error, %Ecto.Changeset{}} = Notes.update_note(note, %{"title" => ""})
      updated_note = Notes.get_note!(team.id, note.id)
      assert updated_note.title == note.title
      assert updated_note.content == note.content
    end

    test "delete_note/1 deletes the note", %{user: user, team: team, horse: horse} do
      note = note_fixture(horse, user)
      assert {:ok, %Note{}} = Notes.delete_note(note)
      assert_raise Ecto.NoResultsError, fn -> Notes.get_note!(team.id, note.id) end
    end

    test "change_note/1 returns a note changeset", %{user: user, horse: horse} do
      note = note_fixture(horse, user)
      assert %Ecto.Changeset{} = Notes.change_note(note)
    end

    test "search_notes/3 finds notes by title and content", %{
      user: user,
      team: team,
      horse: horse
    } do
      note1 =
        note_fixture(horse, user, %{
          "title" => "Important Meeting",
          "content" => "Discuss training"
        })

      note2 =
        note_fixture(horse, user, %{"title" => "Vet Visit", "content" => "Important checkup"})

      _note3 =
        note_fixture(horse, user, %{"title" => "Regular Note", "content" => "Nothing special"})

      # Search by title
      results = Notes.search_notes(team.id, horse.id, "Meeting")
      assert length(results) == 1
      assert List.first(results).id == note1.id

      # Search by content  
      results = Notes.search_notes(team.id, horse.id, "checkup")
      assert length(results) == 1
      assert List.first(results).id == note2.id

      # Search that matches multiple
      results = Notes.search_notes(team.id, horse.id, "Important")
      assert length(results) == 2
    end
  end
end
