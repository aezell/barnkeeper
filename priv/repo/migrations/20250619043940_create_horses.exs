defmodule Barnkeeper.Repo.Migrations.CreateHorses do
  use Ecto.Migration

  def change do
    create table(:horses) do
      add :name, :string, null: false
      add :breed, :string
      add :color, :string
      add :size, :string
      add :gender, :string
      add :birth_date, :date
      add :height_hands, :decimal, precision: 5, scale: 2
      add :weight_lbs, :integer
      add :microchip_number, :string
      add :registration_number, :string
      add :passport_number, :string
      add :insurance_company, :string
      add :insurance_policy, :string
      add :purchase_date, :date
      add :purchase_price, :decimal, precision: 10, scale: 2
      add :active, :boolean, default: true, null: false
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :location_id, references(:locations, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:horses, [:team_id])
    create index(:horses, [:location_id])
    create unique_index(:horses, [:name, :team_id])
  end
end
