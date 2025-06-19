defmodule Barnkeeper.Teams.Membership do
  @moduledoc """
  Membership schema - represents the relationship between users and teams with roles.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Barnkeeper.Accounts.User
  alias Barnkeeper.Teams.Team

  @roles [:owner, :manager, :trainer, :caretaker, :viewer]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "memberships" do
    field :role, Ecto.Enum, values: @roles
    field :active, :boolean, default: true

    belongs_to :user, User
    belongs_to :team, Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :active, :user_id, :team_id])
    |> validate_required([:role, :user_id, :team_id])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint([:user_id, :team_id], name: :memberships_user_id_team_id_index)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:team_id)
  end

  @doc """
  Returns the list of available roles.
  """
  def roles, do: @roles

  @doc """
  Checks if a role has permission for a given action.
  """
  def can?(role, action) do
    permissions = %{
      owner: [:read, :write, :delete, :manage_users, :manage_team],
      manager: [:read, :write, :delete, :manage_users],
      trainer: [:read, :write],
      caretaker: [:read, :write],
      viewer: [:read]
    }

    action in Map.get(permissions, role, [])
  end
end
