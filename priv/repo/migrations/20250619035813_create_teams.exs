defmodule Barnkeeper.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :slug, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teams, [:slug])
  end
end
