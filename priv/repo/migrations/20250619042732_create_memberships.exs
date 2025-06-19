defmodule Barnkeeper.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :role, :string, null: false
      add :active, :boolean, default: true, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:team_id])
    create unique_index(:memberships, [:user_id, :team_id])
  end
end
