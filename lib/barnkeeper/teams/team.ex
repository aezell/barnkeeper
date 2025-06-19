defmodule Barnkeeper.Teams.Team do
  @moduledoc """
  Team schema - represents a barn/farm (tenant entity).
  Each team has isolated data for multi-tenancy.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Teams.Membership
  alias Barnkeeper.Horses.Horse
  alias Barnkeeper.Facilities.Location

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "teams" do
    field :name, :string
    field :description, :string
    field :address, :string
    field :city, :string
    field :state, :string
    field :zip_code, :string
    field :phone, :string
    field :email, :string
    field :website, :string
    field :active, :boolean, default: true

    has_many :memberships, Membership
    has_many :users, through: [:memberships, :user]
    has_many :horses, Horse
    has_many :locations, Location

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :description, :address, :city, :state, :zip_code, 
                    :phone, :email, :website, :active])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:description, max: 500)
    |> validate_length(:address, max: 200)
    |> validate_length(:city, max: 50)
    |> validate_length(:state, max: 50)
    |> validate_length(:zip_code, max: 10)
    |> validate_length(:phone, max: 20)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_format(:website, ~r/^https?:\/\//, message: "must start with http:// or https://")
    |> unique_constraint(:name)
  end
end
