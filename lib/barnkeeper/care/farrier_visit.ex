defmodule Barnkeeper.Care.FarrierVisit do
  @moduledoc """
  FarrierVisit schema - represents farrier visit records for horses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Accounts.User

  @service_types [:trim, :shoes_all, :shoes_front, :shoes_hind, :corrective, :therapeutic, :other]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "farrier_visits" do
    field :service_type, Ecto.Enum, values: @service_types
    field :visit_date, :date
    field :farrier_name, :string
    field :farrier_phone, :string
    field :services_performed, :string
    field :observations, :string
    field :next_visit_date, :date
    field :cost, :decimal
    field :notes, :string

    belongs_to :horse, Horse
    belongs_to :recorded_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(farrier_visit, attrs) do
    farrier_visit
    |> cast(attrs, [:service_type, :visit_date, :farrier_name, :farrier_phone,
                    :services_performed, :observations, :next_visit_date, :cost,
                    :notes, :horse_id, :recorded_by_id])
    |> validate_required([:service_type, :visit_date, :farrier_name, :horse_id, :recorded_by_id])
    |> validate_inclusion(:service_type, @service_types)
    |> validate_length(:farrier_name, min: 1, max: 100)
    |> validate_length(:farrier_phone, max: 20)
    |> validate_number(:cost, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:horse_id)
    |> foreign_key_constraint(:recorded_by_id)
  end

  @doc """
  Returns the list of available service types.
  """
  def service_types, do: @service_types
end
