defmodule Barnkeeper.Repo.Migrations.CreateVetVisits do
  use Ecto.Migration

  def change do
    create table(:vet_visits) do
      add :visit_type, :string, null: false
      add :visit_date, :date, null: false
      add :veterinarian_name, :string, null: false
      add :veterinarian_phone, :string
      add :diagnosis, :text
      add :treatment, :text
      add :medications, :text
      add :follow_up_date, :date
      add :cost, :decimal, precision: 10, scale: 2
      add :notes, :text
      add :horse_id, references(:horses, on_delete: :delete_all), null: false
      add :recorded_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:vet_visits, [:horse_id])
    create index(:vet_visits, [:recorded_by_id])
    create index(:vet_visits, [:visit_date])
  end
end
