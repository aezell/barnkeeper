defmodule BarnkeeperWeb.CalendarLive do
  @moduledoc """
  Calendar LiveView for managing horse activities and scheduling.
  """
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Activities, Horses, Teams}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    # Get user's team
    memberships = Teams.list_user_memberships(user.id)

    team =
      case memberships do
        [membership | _] -> membership.team
        [] -> nil
      end

    if team do
      today = Date.utc_today()
      current_month = Date.beginning_of_month(today)

      socket =
        socket
        |> assign(:team, team)
        |> assign(:view_type, :month)
        |> assign(:current_date, today)
        |> assign(:current_month, current_month)
        |> assign(:calendar_data, %{})
        |> assign(:horses, [])
        |> assign(:selected_horse_id, nil)
        |> assign(:show_ride_form, false)
        |> assign(:selected_date, nil)
        |> assign(:rides, [])

      {:ok, load_calendar_data(socket)}
    else
      # User has no team, redirect to team setup
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    view_type = Map.get(params, "view", "month") |> String.to_atom()
    date_param = Map.get(params, "date")

    current_date =
      case date_param do
        nil -> Date.utc_today()
        date_str -> Date.from_iso8601!(date_str)
      end

    socket =
      socket
      |> assign(:view_type, view_type)
      |> assign(:current_date, current_date)
      |> assign(:current_month, Date.beginning_of_month(current_date))
      |> load_calendar_data()

    {:noreply, socket}
  end

  @impl true
  def handle_event("change_view", %{"view" => view}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/calendar?view=#{view}&date=#{socket.assigns.current_date}"
     )}
  end

  def handle_event("prev_month", _params, socket) do
    prev_month = Date.shift(socket.assigns.current_month, month: -1)

    {:noreply,
     push_patch(socket,
       to: ~p"/calendar?view=#{socket.assigns.view_type}&date=#{prev_month}"
     )}
  end

  def handle_event("next_month", _params, socket) do
    next_month = Date.shift(socket.assigns.current_month, month: 1)

    {:noreply,
     push_patch(socket,
       to: ~p"/calendar?view=#{socket.assigns.view_type}&date=#{next_month}"
     )}
  end

  def handle_event("select_date", %{"date" => date_str}, socket) do
    selected_date = Date.from_iso8601!(date_str)

    socket =
      socket
      |> assign(:selected_date, selected_date)
      |> assign(:show_ride_form, true)

    {:noreply, socket}
  end

  def handle_event("close_form", _params, socket) do
    {:noreply, assign(socket, :show_ride_form, false)}
  end

  def handle_event("schedule_ride", ride_params, socket) do
    ride_attrs =
      ride_params
      |> Map.put("scheduled_by_id", socket.assigns.current_user.id)
      |> Map.put(
        "scheduled_at",
        build_datetime(socket.assigns.selected_date, ride_params["time"])
      )

    case Activities.create_ride(ride_attrs) do
      {:ok, _ride} ->
        socket =
          socket
          |> put_flash(:info, "Ride scheduled successfully")
          |> assign(:show_ride_form, false)
          |> load_calendar_data()

        {:noreply, socket}

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to schedule ride")
        {:noreply, socket}
    end
  end

  # Private functions

  defp load_calendar_data(socket) do
    team_id = socket.assigns.team.id

    case socket.assigns.view_type do
      :month -> load_month_data(socket, team_id)
      :week -> load_week_data(socket, team_id)
      :day -> load_day_data(socket, team_id)
    end
  end

  defp load_month_data(socket, team_id) do
    start_date = Date.beginning_of_month(socket.assigns.current_month)
    end_date = Date.end_of_month(socket.assigns.current_month)

    # Convert to datetime for query
    start_datetime = DateTime.new!(start_date, ~T[00:00:00])
    end_datetime = DateTime.new!(end_date, ~T[23:59:59])

    rides = Activities.list_rides_by_date_range(team_id, start_datetime, end_datetime)
    horses = Horses.list_horses(team_id)

    # Group rides by date
    calendar_data =
      rides
      |> Enum.group_by(fn ride ->
        ride.scheduled_at |> DateTime.to_date()
      end)

    socket
    |> assign(:rides, rides)
    |> assign(:horses, horses)
    |> assign(:calendar_data, calendar_data)
  end

  defp load_week_data(socket, _team_id) do
    # Implementation for week view
    socket
  end

  defp load_day_data(socket, _team_id) do
    # Implementation for day view
    socket
  end

  defp build_datetime(date, time_str) do
    case Time.from_iso8601(time_str <> ":00") do
      {:ok, time} -> DateTime.new!(date, time) |> DateTime.shift_zone!("Etc/UTC")
      {:error, _} -> DateTime.new!(date, ~T[09:00:00]) |> DateTime.shift_zone!("Etc/UTC")
    end
  end

  defp calendar_weeks(month_start) do
    # Get the first day of the calendar grid (might be from previous month)
    calendar_start =
      case Date.day_of_week(month_start) do
        # Monday
        1 -> month_start
        day_of_week -> Date.add(month_start, -(day_of_week - 1))
      end

    # Generate 6 weeks of dates (42 days total)
    0..41
    |> Enum.map(&Date.add(calendar_start, &1))
    |> Enum.chunk_every(7)
  end

  defp in_current_month?(date, current_month) do
    Date.beginning_of_month(date) == Date.beginning_of_month(current_month)
  end

  defp format_month_year(date) do
    "#{month_name(date.month)} #{date.year}"
  end

  defp month_name(1), do: "January"
  defp month_name(2), do: "February"
  defp month_name(3), do: "March"
  defp month_name(4), do: "April"
  defp month_name(5), do: "May"
  defp month_name(6), do: "June"
  defp month_name(7), do: "July"
  defp month_name(8), do: "August"
  defp month_name(9), do: "September"
  defp month_name(10), do: "October"
  defp month_name(11), do: "November"
  defp month_name(12), do: "December"
end
