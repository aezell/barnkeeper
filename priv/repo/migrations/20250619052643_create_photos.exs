defmodule Barnkeeper.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :filename, :string, null: false
      add :original_filename, :string, null: false
      add :content_type, :string, null: false
      add :file_size, :integer, null: false
      add :url, :string, null: false
      add :description, :text
      add :is_primary, :boolean, default: false, null: false
      add :taken_at, :utc_datetime
      add :horse_id, references(:horses, on_delete: :delete_all), null: false
      add :uploaded_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:photos, [:horse_id])
    create index(:photos, [:uploaded_by_id])
    create index(:photos, [:is_primary])
  end
end
