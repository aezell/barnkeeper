defmodule Barnkeeper.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :title, :string, null: false
      add :content, :text, null: false
      add :is_private, :boolean, default: false, null: false
      add :horse_id, references(:horses, on_delete: :delete_all), null: false
      add :author_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:notes, [:horse_id])
    create index(:notes, [:author_id])
    create index(:notes, [:is_private])
  end
end
