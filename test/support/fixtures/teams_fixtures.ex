defmodule Barnkeeper.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Barnkeeper.Teams` context.
  """

  @doc """
  Generate a team with user as admin.
  """
  def team_fixture(user, attrs \\ %{}) do
    team_attrs =
      attrs
      |> Enum.into(%{
        name: "Test Barn #{System.unique_integer([:positive])}",
        description: "A test barn for horses"
      })

    {:ok, %{team: team}} = Barnkeeper.Teams.create_team_with_admin(team_attrs, user)
    team
  end
end
