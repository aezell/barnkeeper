defmodule Barnkeeper.Care do
  @moduledoc """
  The Care context for horse care management with multi-tenant support.
  """

  import Ecto.Query, warn: false
  alias Barnkeeper.Repo
  alias Barnkeeper.Care.{Feeding, VetVisit, FarrierVisit, Vaccination}

  # Feeding functions
  @doc """
  Returns the list of feedings for a horse.
  """
  def list_feedings(team_id, horse_id) do
    from(f in Feeding,
      join: h in assoc(f, :horse),
      where: h.team_id == ^team_id and f.horse_id == ^horse_id,
      order_by: [desc: f.fed_at]
    )
    |> Repo.all()
  end

  @doc """
  Creates a feeding record.
  """
  def create_feeding(attrs \\ %{}) do
    %Feeding{}
    |> Feeding.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feeding record.
  """
  def update_feeding(%Feeding{} = feeding, attrs) do
    feeding
    |> Feeding.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feeding record.
  """
  def delete_feeding(%Feeding{} = feeding) do
    Repo.delete(feeding)
  end

  # Vet visit functions
  @doc """
  Returns the list of vet visits for a horse.
  """
  def list_vet_visits(team_id, horse_id) do
    from(v in VetVisit,
      join: h in assoc(v, :horse),
      where: h.team_id == ^team_id and v.horse_id == ^horse_id,
      order_by: [desc: v.visit_date]
    )
    |> Repo.all()
  end

  @doc """
  Creates a vet visit record.
  """
  def create_vet_visit(attrs \\ %{}) do
    %VetVisit{}
    |> VetVisit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vet visit record.
  """
  def update_vet_visit(%VetVisit{} = vet_visit, attrs) do
    vet_visit
    |> VetVisit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vet visit record.
  """
  def delete_vet_visit(%VetVisit{} = vet_visit) do
    Repo.delete(vet_visit)
  end

  # Farrier visit functions
  @doc """
  Returns the list of farrier visits for a horse.
  """
  def list_farrier_visits(team_id, horse_id) do
    from(f in FarrierVisit,
      join: h in assoc(f, :horse),
      where: h.team_id == ^team_id and f.horse_id == ^horse_id,
      order_by: [desc: f.visit_date]
    )
    |> Repo.all()
  end

  @doc """
  Creates a farrier visit record.
  """
  def create_farrier_visit(attrs \\ %{}) do
    %FarrierVisit{}
    |> FarrierVisit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a farrier visit record.
  """
  def update_farrier_visit(%FarrierVisit{} = farrier_visit, attrs) do
    farrier_visit
    |> FarrierVisit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a farrier visit record.
  """
  def delete_farrier_visit(%FarrierVisit{} = farrier_visit) do
    Repo.delete(farrier_visit)
  end

  # Vaccination functions
  @doc """
  Returns the list of vaccinations for a horse.
  """
  def list_vaccinations(team_id, horse_id) do
    from(v in Vaccination,
      join: h in assoc(v, :horse),
      where: h.team_id == ^team_id and v.horse_id == ^horse_id,
      order_by: [desc: v.administered_date]
    )
    |> Repo.all()
  end

  @doc """
  Creates a vaccination record.
  """
  def create_vaccination(attrs \\ %{}) do
    %Vaccination{}
    |> Vaccination.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vaccination record.
  """
  def update_vaccination(%Vaccination{} = vaccination, attrs) do
    vaccination
    |> Vaccination.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vaccination record.
  """
  def delete_vaccination(%Vaccination{} = vaccination) do
    Repo.delete(vaccination)
  end

  @doc """
  Gets upcoming vaccinations that need to be renewed.
  """
  def list_upcoming_vaccinations(team_id, days_ahead \\ 30) do
    future_date = Date.add(Date.utc_today(), days_ahead)
    
    from(v in Vaccination,
      join: h in assoc(v, :horse),
      where: h.team_id == ^team_id and not is_nil(v.next_due_date) and v.next_due_date <= ^future_date,
      order_by: v.next_due_date
    )
    |> Repo.all()
  end
end
