defmodule Barnkeeper.Repo.Migrations.AddMissingFieldsToRides do
  use Ecto.Migration

  def change do
    # Add status field (enum stored as string)
    alter table(:rides) do
      add :status, :string, null: false, default: "scheduled"
      add :rider_name, :string
      add :instructor_name, :string
      add :discipline, :string
      add :goals, :string
      add :completed_at, :utc_datetime
    end

    # Remove fields that exist in migration but not in schema
    alter table(:rides) do
      remove :distance_miles
      remove :gait
      remove :location
      remove :started_at
      remove :ended_at
      remove :weather_conditions
      remove :temperature_f
      remove :rider_id
    end

    # Add index for status
    create index(:rides, [:status])
  end
end
