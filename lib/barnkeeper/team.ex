defmodule Barnkeeper.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :description, :string
    field :slug, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name, :slug, :description])
    |> unique_constraint(:slug)
  end
end
