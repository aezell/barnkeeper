defmodule Barnkeeper.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string, null: false
      add :location_type, :string, null: false
      add :description, :string
      add :capacity, :integer, default: 1
      add :size_sqft, :integer
      add :has_water, :boolean, default: false, null: false
      add :has_electricity, :boolean, default: false, null: false
      add :has_shelter, :boolean, default: false, null: false
      add :notes, :string
      add :active, :boolean, default: true, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:locations, [:team_id])
    create unique_index(:locations, [:name, :team_id])
  end
end
