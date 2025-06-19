defmodule Barnkeeper.Facilities do
  @moduledoc """
  The Facilities context for location management with multi-tenant support.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Facilities.Location

  @doc """
  Returns the list of locations for a team.
  """
  def list_locations(team_id) do
    from(l in Location, where: l.team_id == ^team_id, order_by: l.name)
    |> Repo.all()
  end

  @doc """
  Gets a single location within a team.
  """
  def get_location!(team_id, id) do
    from(l in Location, where: l.team_id == ^team_id and l.id == ^id)
    |> Repo.one!()
  end

  @doc """
  Creates a location for a team.
  """
  def create_location(team_id, attrs \\ %{}) do
    attrs = Map.put(attrs, :team_id, team_id)

    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location within a team.
  """
  def update_location(team_id, %Location{} = location, attrs) do
    # Ensure location belongs to team
    if location.team_id != team_id do
      {:error, :not_found}
    else
      location
      |> Location.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a location within a team.
  """
  def delete_location(team_id, %Location{} = location) do
    # Ensure location belongs to team
    if location.team_id != team_id do
      {:error, :not_found}
    else
      Repo.delete(location)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.
  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  @doc """
  Gets available locations (not occupied) within a team.
  """
  def list_available_locations(team_id) do
    from(l in Location,
      left_join: h in assoc(l, :horses),
      where: l.team_id == ^team_id and is_nil(h.id),
      order_by: l.name
    )
    |> Repo.all()
  end

  @doc """
  Gets locations by type within a team.
  """
  def list_locations_by_type(team_id, location_type) do
    from(l in Location,
      where: l.team_id == ^team_id and l.location_type == ^location_type,
      order_by: l.name
    )
    |> Repo.all()
  end
end
