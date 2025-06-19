defmodule Barnkeeper.Repo.Migrations.CreateFarrierVisits do
  use Ecto.Migration

  def change do
    create table(:farrier_visits) do
      add :service_type, :string, null: false
      add :visit_date, :date, null: false
      add :farrier_name, :string, null: false
      add :farrier_phone, :string
      add :services_performed, :text
      add :observations, :text
      add :next_visit_date, :date
      add :cost, :decimal, precision: 10, scale: 2
      add :notes, :text
      add :horse_id, references(:horses, on_delete: :delete_all), null: false
      add :recorded_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:farrier_visits, [:horse_id])
    create index(:farrier_visits, [:recorded_by_id])
    create index(:farrier_visits, [:visit_date])
  end
end
