defmodule Barnkeeper.Repo.Migrations.ConvertTeamsToBigint do
  use Ecto.Migration

  def up do
    # Drop all foreign key constraints first
    drop constraint(:memberships, "memberships_team_id_fkey")
    drop constraint(:horses, "horses_team_id_fkey")
    drop constraint(:locations, "locations_team_id_fkey")

    # Drop existing tables and recreate with bigint IDs
    drop table(:teams)

    create table(:teams) do
      add :name, :string, null: false
      add :description, :text
      add :address, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string
      add :phone, :string
      add :email, :string
      add :website, :string
      add :active, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teams, [:name])

    # Recreate foreign key constraints with proper types
    alter table(:memberships) do
      modify :team_id, references(:teams, on_delete: :delete_all), null: false
    end

    alter table(:horses) do
      modify :team_id, references(:teams, on_delete: :delete_all), null: false
    end

    alter table(:locations) do
      modify :team_id, references(:teams, on_delete: :delete_all), null: false
    end

    create_if_not_exists index(:memberships, [:team_id])
    create_if_not_exists unique_index(:memberships, [:user_id, :team_id])
    create_if_not_exists index(:horses, [:team_id])
    create_if_not_exists unique_index(:horses, [:name, :team_id])
    create_if_not_exists index(:locations, [:team_id])
    create_if_not_exists unique_index(:locations, [:name, :team_id])
  end

  def down do
    # This is a destructive migration, so we can't easily reverse it
    raise "This migration cannot be rolled back"
  end
end
