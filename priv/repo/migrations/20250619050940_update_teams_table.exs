defmodule Barnkeeper.Repo.Migrations.UpdateTeamsTable do
  use Ecto.Migration

  def change do
    # Add the missing columns to the teams table
    alter table(:teams) do
      add :address, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string
      add :phone, :string
      add :email, :string
      add :website, :string
      add :active, :boolean, default: true
    end

    # Add a unique index on name
    create unique_index(:teams, [:name])
  end
end
