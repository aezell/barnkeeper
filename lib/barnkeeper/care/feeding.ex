defmodule Barnkeeper.Care.Feeding do
  @moduledoc """
  Feeding schema - represents feeding records for horses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Accounts.User

  @feed_types [:hay, :grain, :pellets, :supplements, :treats, :other]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "feedings" do
    field :feed_type, Ecto.Enum, values: @feed_types
    field :feed_name, :string
    field :amount, :decimal
    field :unit, :string
    field :fed_at, :utc_datetime
    field :notes, :string

    belongs_to :horse, Horse
    belongs_to :fed_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(feeding, attrs) do
    feeding
    |> cast(attrs, [:feed_type, :feed_name, :amount, :unit, :fed_at, :notes, :horse_id, :fed_by_id])
    |> validate_required([:feed_type, :feed_name, :amount, :unit, :fed_at, :horse_id, :fed_by_id])
    |> validate_inclusion(:feed_type, @feed_types)
    |> validate_length(:feed_name, min: 1, max: 100)
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:unit, min: 1, max: 20)
    |> foreign_key_constraint(:horse_id)
    |> foreign_key_constraint(:fed_by_id)
  end

  @doc """
  Returns the list of available feed types.
  """
  def feed_types, do: @feed_types
end
