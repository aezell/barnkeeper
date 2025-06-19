defmodule Barnkeeper.Care.VetVisit do
  @moduledoc """
  VetVisit schema - represents veterinary visit records for horses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Accounts.User

  @visit_types [:routine, :emergency, :dental, :reproductive, :surgery, :other]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "vet_visits" do
    field :visit_type, Ecto.Enum, values: @visit_types
    field :visit_date, :date
    field :veterinarian_name, :string
    field :veterinarian_phone, :string
    field :diagnosis, :string
    field :treatment, :string
    field :medications, :string
    field :follow_up_date, :date
    field :cost, :decimal
    field :notes, :string

    belongs_to :horse, Horse
    belongs_to :recorded_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vet_visit, attrs) do
    vet_visit
    |> cast(attrs, [:visit_type, :visit_date, :veterinarian_name, :veterinarian_phone,
                    :diagnosis, :treatment, :medications, :follow_up_date, :cost,
                    :notes, :horse_id, :recorded_by_id])
    |> validate_required([:visit_type, :visit_date, :veterinarian_name, :horse_id, :recorded_by_id])
    |> validate_inclusion(:visit_type, @visit_types)
    |> validate_length(:veterinarian_name, min: 1, max: 100)
    |> validate_length(:veterinarian_phone, max: 20)
    |> validate_number(:cost, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:horse_id)
    |> foreign_key_constraint(:recorded_by_id)
  end

  @doc """
  Returns the list of available visit types.
  """
  def visit_types, do: @visit_types
end
