defmodule Barnkeeper.Care.Vaccination do
  @moduledoc """
  Vaccination schema - represents vaccination records for horses.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Accounts.User

  schema "vaccinations" do
    field :vaccine_name, :string
    field :manufacturer, :string
    field :lot_number, :string
    field :administered_date, :date
    field :administered_by, :string
    field :site, :string
    field :dose, :string
    field :next_due_date, :date
    field :notes, :string

    belongs_to :horse, Horse
    belongs_to :recorded_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vaccination, attrs) do
    vaccination
    |> cast(attrs, [
      :vaccine_name,
      :manufacturer,
      :lot_number,
      :administered_date,
      :administered_by,
      :site,
      :dose,
      :next_due_date,
      :notes,
      :horse_id,
      :recorded_by_id
    ])
    |> validate_required([:vaccine_name, :administered_date, :horse_id, :recorded_by_id])
    |> validate_length(:vaccine_name, min: 1, max: 100)
    |> validate_length(:manufacturer, max: 100)
    |> validate_length(:lot_number, max: 50)
    |> validate_length(:administered_by, max: 100)
    |> validate_length(:site, max: 50)
    |> validate_length(:dose, max: 50)
    |> foreign_key_constraint(:horse_id)
    |> foreign_key_constraint(:recorded_by_id)
  end

  @doc """
  Checks if the vaccination is due for renewal.
  """
  def due_soon?(%__MODULE__{next_due_date: nil}), do: false

  def due_soon?(%__MODULE__{next_due_date: next_due_date}, days_ahead \\ 30) do
    future_date = Date.add(Date.utc_today(), days_ahead)
    Date.compare(next_due_date, future_date) != :gt
  end

  @doc """
  Checks if the vaccination is overdue.
  """
  def overdue?(%__MODULE__{next_due_date: nil}), do: false

  def overdue?(%__MODULE__{next_due_date: next_due_date}) do
    Date.compare(next_due_date, Date.utc_today()) == :lt
  end
end
