defmodule Barnkeeper.Repo.Migrations.AddCustomFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :phone, :string
      add :active, :boolean, default: true, null: false
    end
  end
end
