defmodule Barnkeeper.Notes.Note do
  @moduledoc """
  Note schema - represents notes/journal entries for horses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "notes" do
    field :title, :string
    field :content, :string
    field :is_private, :boolean, default: false

    belongs_to :horse, Horse
    belongs_to :author, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:title, :content, :is_private, :horse_id, :author_id])
    |> validate_required([:title, :content, :horse_id, :author_id])
    |> validate_length(:title, min: 1, max: 200)
    |> validate_length(:content, min: 1)
    |> foreign_key_constraint(:horse_id)
    |> foreign_key_constraint(:author_id)
  end
end
