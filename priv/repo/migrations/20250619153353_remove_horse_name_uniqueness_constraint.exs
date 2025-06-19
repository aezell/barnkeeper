defmodule Barnkeeper.Repo.Migrations.RemoveHorseNameUniquenessConstraint do
  use Ecto.Migration

  def change do
    drop unique_index(:horses, [:name, :team_id])
  end
end
