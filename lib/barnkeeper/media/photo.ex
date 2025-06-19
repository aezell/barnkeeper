defmodule Barnkeeper.Media.Photo do
  @moduledoc """
  Photo schema - represents photo storage for horses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Accounts.User

  schema "photos" do
    field :filename, :string
    field :original_filename, :string
    field :content_type, :string
    field :file_size, :integer
    field :url, :string
    field :description, :string
    field :is_primary, :boolean, default: false
    field :taken_at, :utc_datetime

    belongs_to :horse, Horse
    belongs_to :uploaded_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [
      :filename,
      :original_filename,
      :content_type,
      :file_size,
      :url,
      :description,
      :is_primary,
      :taken_at,
      :horse_id,
      :uploaded_by_id
    ])
    |> validate_required([
      :filename,
      :original_filename,
      :content_type,
      :file_size,
      :url,
      :horse_id,
      :uploaded_by_id
    ])
    |> validate_length(:filename, min: 1, max: 255)
    |> validate_length(:original_filename, min: 1, max: 255)
    |> validate_length(:content_type, min: 1, max: 100)
    |> validate_number(:file_size, greater_than: 0)
    |> validate_length(:url, min: 1, max: 500)
    |> validate_length(:description, max: 500)
    |> foreign_key_constraint(:horse_id)
    |> foreign_key_constraint(:uploaded_by_id)
    |> validate_content_type()
  end

  defp validate_content_type(changeset) do
    case get_field(changeset, :content_type) do
      "image/" <> _ -> changeset
      _ -> add_error(changeset, :content_type, "must be an image")
    end
  end

  @doc """
  Returns the file size in a human-readable format.
  """
  def formatted_file_size(%__MODULE__{file_size: size}) when size < 1024, do: "#{size} B"

  def formatted_file_size(%__MODULE__{file_size: size}) when size < 1024 * 1024 do
    "#{Float.round(size / 1024, 1)} KB"
  end

  def formatted_file_size(%__MODULE__{file_size: size}) do
    "#{Float.round(size / (1024 * 1024), 1)} MB"
  end
end
