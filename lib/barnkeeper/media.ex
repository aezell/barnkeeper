defmodule Barnkeeper.Media do
  @moduledoc """
  The Media context for photo management with multi-tenant support.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Media.Photo

  @doc """
  Returns the list of photos for a horse.
  """
  def list_photos(team_id, horse_id) do
    from(p in Photo,
      join: h in assoc(p, :horse),
      where: h.team_id == ^team_id and p.horse_id == ^horse_id,
      order_by: [desc: p.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single photo within a team.
  """
  def get_photo!(team_id, id) do
    from(p in Photo,
      join: h in assoc(p, :horse),
      where: h.team_id == ^team_id and p.id == ^id
    )
    |> Repo.one!()
  end

  @doc """
  Creates a photo.
  """
  def create_photo(attrs \\ %{}) do
    %Photo{}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a photo.
  """
  def update_photo(%Photo{} = photo, attrs) do
    photo
    |> Photo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a photo.
  """
  def delete_photo(%Photo{} = photo) do
    Repo.delete(photo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking photo changes.
  """
  def change_photo(%Photo{} = photo, attrs \\ %{}) do
    Photo.changeset(photo, attrs)
  end

  @doc """
  Gets the primary photo for a horse.
  """
  def get_primary_photo(team_id, horse_id) do
    from(p in Photo,
      join: h in assoc(p, :horse),
      where: h.team_id == ^team_id and p.horse_id == ^horse_id and p.is_primary == true
    )
    |> Repo.one()
  end
end
