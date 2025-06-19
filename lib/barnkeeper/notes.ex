defmodule Barnkeeper.Notes do
  @moduledoc """
  The Notes context for journal entries with multi-tenant support.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Notes.Note

  @doc """
  Returns the list of notes for a horse.
  """
  def list_notes(team_id, horse_id) do
    from(n in Note,
      join: h in assoc(n, :horse),
      where: h.team_id == ^team_id and n.horse_id == ^horse_id,
      order_by: [desc: n.inserted_at],
      preload: :author
    )
    |> Repo.all()
  end

  @doc """
  Gets a single note within a team.
  """
  def get_note!(team_id, id) do
    from(n in Note,
      join: h in assoc(n, :horse),
      where: h.team_id == ^team_id and n.id == ^id,
      preload: [:horse, :author]
    )
    |> Repo.one!()
  end

  @doc """
  Creates a note.
  """
  def create_note(attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a note.
  """
  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a note.
  """
  def delete_note(%Note{} = note) do
    Repo.delete(note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.
  """
  def change_note(%Note{} = note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end

  @doc """
  Searches notes for a horse by content.
  """
  def search_notes(team_id, horse_id, search_term) do
    search_term = "%#{search_term}%"
    
    from(n in Note,
      join: h in assoc(n, :horse),
      where: h.team_id == ^team_id and n.horse_id == ^horse_id and
             (ilike(n.title, ^search_term) or ilike(n.content, ^search_term)),
      order_by: [desc: n.inserted_at],
      preload: :author
    )
    |> Repo.all()
  end
end
