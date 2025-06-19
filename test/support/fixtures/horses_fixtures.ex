defmodule Barnkeeper.HorsesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Barnkeeper.Horses` context.
  """

  @doc """
  Generate a horse.
  """
  def horse_fixture(team, attrs \\ %{}) do
    {:ok, horse} =
      attrs
      |> Enum.into(%{
        "name" => "Test Horse",
        "breed" => "Thoroughbred",
        "color" => "Bay",
        "birth_date" => ~D[2015-01-01],
        "size" => "horse"
      })
      |> then(&Barnkeeper.Horses.create_horse(team.id, &1))

    horse
  end
end
