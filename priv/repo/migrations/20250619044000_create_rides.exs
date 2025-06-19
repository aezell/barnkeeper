defmodule Barnkeeper.Repo.Migrations.CreateRides do
  use Ecto.Migration

  def change do
    create table(:rides) do
      add :ride_type, :string, null: false
      add :duration_minutes, :integer
      add :distance_miles, :decimal, precision: 5, scale: 2
      add :gait, :string
      add :location, :string
      add :scheduled_at, :utc_datetime, null: false
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime
      add :notes, :text
      add :weather_conditions, :string
      add :temperature_f, :integer
      add :horse_id, references(:horses, on_delete: :delete_all), null: false
      add :rider_id, references(:users, on_delete: :delete_all), null: false
      add :scheduled_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:rides, [:horse_id])
    create index(:rides, [:rider_id])
    create index(:rides, [:scheduled_by_id])
    create index(:rides, [:scheduled_at])
  end
end
