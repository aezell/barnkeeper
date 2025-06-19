defmodule Barnkeeper.Repo.Migrations.CreateFeedings do
  use Ecto.Migration

  def change do
    create table(:feedings) do
      add :feed_type, :string, null: false
      add :feed_name, :string, null: false
      add :amount, :decimal, precision: 8, scale: 2, null: false
      add :unit, :string, null: false
      add :fed_at, :utc_datetime, null: false
      add :notes, :string
      add :horse_id, references(:horses, on_delete: :delete_all), null: false
      add :fed_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:feedings, [:horse_id])
    create index(:feedings, [:fed_by_id])
    create index(:feedings, [:fed_at])
  end
end
