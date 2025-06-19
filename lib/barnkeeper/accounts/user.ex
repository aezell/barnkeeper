defmodule Barnkeeper.Accounts.User do
  @moduledoc """
  User schema - represents people who use the system.
  Users can be members of multiple teams (barns/farms).
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Teams.Membership

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :active, :boolean, default: true

    has_many :memberships, Membership
    has_many :teams, through: [:memberships, :team]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :phone, :active])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_length(:first_name, min: 1, max: 50)
    |> validate_length(:last_name, min: 1, max: 50)
    |> validate_length(:phone, max: 20)
    |> unique_constraint(:email)
  end

  @doc """
  Returns the user's full name.
  """
  def full_name(%__MODULE__{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end
end
