defmodule Barnkeeper.Activities.Ride do
  @moduledoc """
  Ride schema - represents ride scheduling and records for horses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Accounts.User

  @ride_types [:training, :lesson, :trail, :competition, :exercise, :other]
  @statuses [:scheduled, :completed, :cancelled, :no_show]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "rides" do
    field :ride_type, Ecto.Enum, values: @ride_types
    field :status, Ecto.Enum, values: @statuses, default: :scheduled
    field :scheduled_at, :utc_datetime
    field :duration_minutes, :integer
    field :rider_name, :string
    field :instructor_name, :string
    field :discipline, :string
    field :goals, :string
    field :notes, :string
    field :completed_at, :utc_datetime

    belongs_to :horse, Horse
    belongs_to :scheduled_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ride, attrs) do
    ride
    |> cast(attrs, [:ride_type, :status, :scheduled_at, :duration_minutes,
                    :rider_name, :instructor_name, :discipline, :goals,
                    :notes, :completed_at, :horse_id, :scheduled_by_id])
    |> validate_required([:ride_type, :scheduled_at, :horse_id, :scheduled_by_id])
    |> validate_inclusion(:ride_type, @ride_types)
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:duration_minutes, greater_than: 0, less_than: 480) # Max 8 hours
    |> validate_length(:rider_name, max: 100)
    |> validate_length(:instructor_name, max: 100)
    |> validate_length(:discipline, max: 50)
    |> foreign_key_constraint(:horse_id)
    |> foreign_key_constraint(:scheduled_by_id)
    |> validate_completed_at_consistency()
  end

  defp validate_completed_at_consistency(changeset) do
    status = get_field(changeset, :status)
    completed_at = get_field(changeset, :completed_at)

    case {status, completed_at} do
      {:completed, nil} ->
        add_error(changeset, :completed_at, "must be set when status is completed")
      {status, completed_at} when status != :completed and not is_nil(completed_at) ->
        add_error(changeset, :completed_at, "should only be set when status is completed")
      _ ->
        changeset
    end
  end

  @doc """
  Returns the list of available ride types.
  """
  def ride_types, do: @ride_types

  @doc """
  Returns the list of available statuses.
  """
  def statuses, do: @statuses

  @doc """
  Checks if the ride is in the past.
  """
  def past?(%__MODULE__{scheduled_at: scheduled_at}) do
    DateTime.compare(scheduled_at, DateTime.utc_now()) == :lt
  end

  @doc """
  Checks if the ride is upcoming (within next 24 hours).
  """
  def upcoming?(%__MODULE__{scheduled_at: scheduled_at}) do
    now = DateTime.utc_now()
    tomorrow = DateTime.add(now, 24 * 60 * 60, :second)
    
    DateTime.compare(scheduled_at, now) != :lt and
    DateTime.compare(scheduled_at, tomorrow) != :gt
  end
end
