defmodule Barnkeeper.Horses.Horse do
  @moduledoc """
  Horse schema - the main entity representing horses with multi-tenant support.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Teams.Team
  alias Barnkeeper.Facilities.Location
  alias Barnkeeper.Care.{Feeding, VetVisit, FarrierVisit, Vaccination}
  alias Barnkeeper.Activities.Ride
  alias Barnkeeper.Media.Photo
  alias Barnkeeper.Notes.Note

  @sizes [:pony, :horse, :draft]
  @genders [:mare, :gelding, :stallion, :filly, :colt]
  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "horses" do
    field :name, :string
    field :breed, :string
    field :color, :string
    field :size, Ecto.Enum, values: @sizes
    field :gender, Ecto.Enum, values: @genders
    field :birth_date, :date
    field :height_hands, :decimal
    field :weight_lbs, :integer
    field :microchip_number, :string
    field :registration_number, :string
    field :passport_number, :string
    field :insurance_company, :string
    field :insurance_policy, :string
    field :purchase_date, :date
    field :purchase_price, :decimal
    field :active, :boolean, default: true

    belongs_to :team, Team
    belongs_to :location, Location

    has_many :feedings, Feeding
    has_many :vet_visits, VetVisit
    has_many :farrier_visits, FarrierVisit
    has_many :vaccinations, Vaccination
    has_many :rides, Ride
    has_many :photos, Photo
    has_many :notes, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(horse, attrs) do
    horse
    |> cast(attrs, [:name, :breed, :color, :size, :gender, :birth_date,
                    :height_hands, :weight_lbs, :microchip_number,
                    :registration_number, :passport_number, :insurance_company,
                    :insurance_policy, :purchase_date, :purchase_price,
                    :active, :team_id, :location_id])
    |> validate_required([:name, :team_id])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:breed, max: 50)
    |> validate_length(:color, max: 50)
    |> validate_inclusion(:size, @sizes)
    |> validate_inclusion(:gender, @genders)
    |> validate_number(:height_hands, greater_than: 0, less_than: 25)
    |> validate_number(:weight_lbs, greater_than: 0, less_than: 3000)
    |> validate_length(:microchip_number, max: 20)
    |> validate_length(:registration_number, max: 50)
    |> validate_length(:passport_number, max: 50)
    |> validate_length(:insurance_company, max: 100)
    |> validate_length(:insurance_policy, max: 100)
    |> validate_number(:purchase_price, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:location_id)
    |> unique_constraint([:name, :team_id], name: :horses_name_team_id_index)
  end

  @doc """
  Returns the list of available sizes.
  """
  def sizes, do: @sizes

  @doc """
  Returns the list of available genders.
  """
  def genders, do: @genders

  @doc """
  Calculates the horse's age in years.
  """
  def age(%__MODULE__{birth_date: nil}), do: nil
  def age(%__MODULE__{birth_date: birth_date}) do
    today = Date.utc_today()
    Date.diff(today, birth_date) |> div(365)
  end

  @doc """
  Returns a formatted height string.
  """
  def formatted_height(%__MODULE__{height_hands: nil}), do: nil
  def formatted_height(%__MODULE__{height_hands: height}) do
    hands = Decimal.to_integer(Decimal.round(height, 0))
    inches = Decimal.to_float(Decimal.rem(height, 1)) * 4 |> round()
    "#{hands}.#{inches} hands"
  end
end
