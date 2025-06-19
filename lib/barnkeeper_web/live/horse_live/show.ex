defmodule BarnkeeperWeb.HorseLive.Show do
  use BarnkeeperWeb, :live_view

  alias Barnkeeper.{Horses, Teams, Media}

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
      {:ok, assign(socket, :team, team)}
    else
      {:ok, push_navigate(socket, to: ~p"/team/setup")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    horse = Horses.get_horse!(socket.assigns.team.id, id)
    photos = Media.list_photos(socket.assigns.team.id, horse.id)

    live_action = socket.assigns[:live_action] || :show

    page_title =
      case live_action do
        :upload_photos -> "Upload Photos - #{horse.name}"
        :edit -> "Edit #{horse.name}"
        _ -> horse.name
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title)
     |> assign(:horse, horse)
     |> assign(:photos, photos)
     |> assign(:live_action, live_action)}
  end

  @impl true
  def handle_info({BarnkeeperWeb.HorseLive.FormComponent, {:saved, horse}}, socket) do
    {:noreply, assign(socket, :horse, horse)}
  end

  @impl true
  def handle_info({:photos_uploaded, count}, socket) do
    photos = Media.list_photos(socket.assigns.team.id, socket.assigns.horse.id)

    {:noreply,
     socket
     |> assign(:photos, photos)
     |> put_flash(:info, "#{count} photo(s) uploaded successfully!")}
  end

  @impl true
  def handle_info(:refresh_photos, socket) do
    photos = Media.list_photos(socket.assigns.team.id, socket.assigns.horse.id)
    {:noreply, assign(socket, :photos, photos)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Horses.delete_horse(socket.assigns.team.id, socket.assigns.horse)

    {:noreply, push_navigate(socket, to: ~p"/horses")}
  end
end
