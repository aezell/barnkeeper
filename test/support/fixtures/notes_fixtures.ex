defmodule Barnkeeper.NotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Barnkeeper.Notes` context.
  """

  @doc """
  Generate a note.
  """
  def note_fixture(horse, author, attrs \\ %{}) do
    {:ok, note} =
      attrs
      |> Enum.into(%{
        "title" => "Test Note",
        "content" => "This is a test note content.",
        "is_private" => false,
        "horse_id" => horse.id,
        "author_id" => author.id
      })
      |> Barnkeeper.Notes.create_note()

    note
  end
end
