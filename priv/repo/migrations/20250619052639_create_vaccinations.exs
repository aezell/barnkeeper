defmodule Barnkeeper.Repo.Migrations.CreateVaccinations do
  use Ecto.Migration

  def change do
    create table(:vaccinations) do
      add :vaccine_name, :string, null: false
      add :manufacturer, :string
      add :lot_number, :string
      add :administered_date, :date, null: false
      add :administered_by, :string
      add :site, :string
      add :dose, :string
      add :next_due_date, :date
      add :notes, :text
      add :horse_id, references(:horses, on_delete: :delete_all), null: false
      add :recorded_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:vaccinations, [:horse_id])
    create index(:vaccinations, [:recorded_by_id])
    create index(:vaccinations, [:administered_date])
    create index(:vaccinations, [:next_due_date])
  end
end
