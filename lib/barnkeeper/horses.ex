defmodule Barnkeeper.Horses do
  @moduledoc """
  The Horses context for horse management with multi-tenant support.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Horses.Horse

  @doc """
  Returns the list of horses for a team.
  """
  def list_horses(team_id) do
    primary_photos_query = from(p in Barnkeeper.Media.Photo, where: p.is_primary == true)

    from(h in Horse, where: h.team_id == ^team_id)
    |> preload(photos: ^primary_photos_query)
    |> Repo.all()
  end

  @doc """
  Gets a single horse within a team.
  """
  def get_horse!(team_id, id) do
    from(h in Horse, where: h.team_id == ^team_id and h.id == ^id)
    |> preload(:notes)
    |> Repo.one!()
  end

  @doc """
  Creates a horse for a team.
  """
  def create_horse(team_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "team_id", team_id)

    %Horse{}
    |> Horse.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a horse within a team.
  """
  def update_horse(team_id, %Horse{} = horse, attrs) do
    # Ensure horse belongs to team
    if horse.team_id != team_id do
      {:error, :not_found}
    else
      horse
      |> Horse.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a horse within a team.
  """
  def delete_horse(team_id, %Horse{} = horse) do
    # Ensure horse belongs to team
    if horse.team_id != team_id do
      {:error, :not_found}
    else
      Repo.delete(horse)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking horse changes.
  """
  def change_horse(%Horse{} = horse, attrs \\ %{}) do
    Horse.changeset(horse, attrs)
  end

  @doc """
  Searches horses by name within a team.
  """
  def search_horses(team_id, search_term) do
    search_term = "%#{search_term}%"

    from(h in Horse,
      where: h.team_id == ^team_id and ilike(h.name, ^search_term),
      order_by: h.name
    )
    |> Repo.all()
  end

  @doc """
  Gets horses by location within a team.
  """
  def get_horses_by_location(team_id, location_id) do
    from(h in Horse,
      where: h.team_id == ^team_id and h.location_id == ^location_id
    )
    |> Repo.all()
  end
end
