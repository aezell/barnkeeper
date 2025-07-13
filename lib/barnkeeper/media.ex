defmodule Barnkeeper.Media do
  @moduledoc """
  The Media context for photo management with multi-tenant support.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Media.Photo
  alias Barnkeeper.Media.S3Uploader

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
    # Delete from S3 first
    if String.contains?(photo.url, "amazonaws.com") do
      case S3Uploader.extract_key_from_url(photo.url) do
        # Skip S3 deletion if we can't extract the key
        nil -> :ok
        key -> S3Uploader.delete_file(key)
      end
    end

    # Delete from database
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

  @doc """
  Sets a photo as the primary photo for a horse, unsetting any existing primary.
  """
  def set_primary_photo(team_id, photo_id) do
    Repo.transaction(fn ->
      # Get the photo to ensure it exists and belongs to the team
      photo = get_photo!(team_id, photo_id)

      # Unset any existing primary photos for this horse
      {count, _} =
        from(p in Photo,
          join: h in assoc(p, :horse),
          where: h.team_id == ^team_id and p.horse_id == ^photo.horse_id and p.is_primary == true
        )
        |> Repo.update_all(set: [is_primary: false])

      # Set this photo as primary
      {:ok, updated_photo} = update_photo(photo, %{is_primary: true})
      {count, updated_photo}
    end)
  end

  @doc """
  Deletes a photo with team validation.
  """
  def delete_photo(team_id, photo_id) do
    photo = get_photo!(team_id, photo_id)
    delete_photo(photo)
  end
end
