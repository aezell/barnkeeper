defmodule Barnkeeper.Facilities.Location do
  @moduledoc """
  Location schema - represents stalls, paddocks, pastures, etc.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Teams.Team
  alias Barnkeeper.Horses.Horse

  @location_types [:stall, :paddock, :pasture, :arena, :round_pen, :wash_rack, :other]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "locations" do
    field :name, :string
    field :location_type, Ecto.Enum, values: @location_types
    field :description, :string
    field :capacity, :integer, default: 1
    field :size_sqft, :integer
    field :has_water, :boolean, default: false
    field :has_electricity, :boolean, default: false
    field :has_shelter, :boolean, default: false
    field :notes, :string
    field :active, :boolean, default: true

    belongs_to :team, Team
    has_many :horses, Horse

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :location_type, :description, :capacity, :size_sqft,
                    :has_water, :has_electricity, :has_shelter, :notes, :active, :team_id])
    |> validate_required([:name, :location_type, :team_id])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_inclusion(:location_type, @location_types)
    |> validate_length(:description, max: 500)
    |> validate_number(:capacity, greater_than: 0)
    |> validate_number(:size_sqft, greater_than: 0)
    |> foreign_key_constraint(:team_id)
    |> unique_constraint([:name, :team_id], name: :locations_name_team_id_index)
  end

  @doc """
  Returns the list of available location types.
  """
  def location_types, do: @location_types

  @doc """
  Checks if the location is occupied (has horses).
  """
  def occupied?(%__MODULE__{horses: horses}) when is_list(horses) do
    length(horses) > 0
  end
  def occupied?(_), do: false

  @doc """
  Returns the number of available spots in the location.
  """
  def available_capacity(%__MODULE__{capacity: capacity, horses: horses}) when is_list(horses) do
    capacity - length(horses)
  end
  def available_capacity(%__MODULE__{capacity: capacity}), do: capacity
end
