defmodule Barnkeeper.Activities do
  @moduledoc """
  The Activities context for ride scheduling and management with multi-tenant support.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Activities.Ride

  @doc """
  Returns the list of rides for a horse.
  """
  def list_rides(team_id, horse_id) do
    from(r in Ride,
      join: h in assoc(r, :horse),
      where: h.team_id == ^team_id and r.horse_id == ^horse_id,
      order_by: [desc: r.scheduled_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of rides for a team within a date range.
  """
  def list_rides_by_date_range(team_id, start_date, end_date) do
    from(r in Ride,
      join: h in assoc(r, :horse),
      where:
        h.team_id == ^team_id and
          r.scheduled_at >= ^start_date and
          r.scheduled_at <= ^end_date,
      order_by: r.scheduled_at,
      preload: :horse
    )
    |> Repo.all()
  end

  @doc """
  Gets upcoming rides for a team.
  """
  def list_upcoming_rides(team_id, days_ahead \\ 7) do
    future_datetime = DateTime.add(DateTime.utc_now(), days_ahead * 24 * 60 * 60, :second)

    from(r in Ride,
      join: h in assoc(r, :horse),
      where:
        h.team_id == ^team_id and
          r.scheduled_at >= fragment("NOW()") and
          r.scheduled_at <= ^future_datetime,
      order_by: r.scheduled_at,
      preload: :horse
    )
    |> Repo.all()
  end

  @doc """
  Creates a ride.
  """
  def create_ride(attrs \\ %{}) do
    %Ride{}
    |> Ride.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ride.
  """
  def update_ride(%Ride{} = ride, attrs) do
    ride
    |> Ride.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ride.
  """
  def delete_ride(%Ride{} = ride) do
    Repo.delete(ride)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ride changes.
  """
  def change_ride(%Ride{} = ride, attrs \\ %{}) do
    Ride.changeset(ride, attrs)
  end
end
