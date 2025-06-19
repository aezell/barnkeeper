defmodule Barnkeeper.Teams do
  @moduledoc """
  The Teams context for multi-tenant team (barn/farm) management.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Teams.{Team, Membership}
  alias Barnkeeper.Accounts.User

  @doc """
  Returns the list of teams.
  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.
  """
  def get_team!(id), do: Repo.get!(Team, id)

  @doc """
  Creates a team.
  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.
  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.
  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.
  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  @doc """
  Gets all memberships for a team.
  """
  def list_memberships(team_id) do
    from(m in Membership,
      where: m.team_id == ^team_id,
      preload: :user
    )
    |> Repo.all()
  end

  @doc """
  Gets all memberships for a user.
  """
  def list_user_memberships(user_id) do
    from(m in Membership,
      where: m.user_id == ^user_id,
      preload: :team
    )
    |> Repo.all()
  end

  @doc """
  Creates a membership between a user and team.
  """
  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a membership.
  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.
  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Checks if a user has access to a team.
  """
  def user_has_team_access?(user_id, team_id, role \\ nil) do
    query = from(m in Membership,
      where: m.user_id == ^user_id and m.team_id == ^team_id
    )

    query = if role do
      from(m in query, where: m.role == ^role)
    else
      query
    end

    Repo.exists?(query)
  end

  @doc """
  Gets a user's role in a team.
  """
  def get_user_team_role(user_id, team_id) do
    case Repo.get_by(Membership, user_id: user_id, team_id: team_id) do
      nil -> nil
      membership -> membership.role
    end
  end
end
