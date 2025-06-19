defmodule BarnkeeperWeb.HorseLive.PhotoGalleryComponent do
  @moduledoc """
  Photo gallery component for displaying horse photos.
  """
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Media

  @impl true
  def render(assigns) do
    ~H"""
    <div id="photo-gallery">
      <%= if @photos == [] do %>
        <div class="text-center py-8">
          <svg
            class="mx-auto h-12 w-12 text-gray-400"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1"
              d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
            />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">No photos</h3>
          <p class="mt-1 text-sm text-gray-500">Get started by uploading a photo.</p>
        </div>
      <% else %>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          <%= for photo <- @photos do %>
            <div class="relative group">
              <div class="aspect-w-1 aspect-h-1 bg-gray-200 rounded-lg overflow-hidden">
                <img
                  src={photo.url}
                  alt={photo.description || "Horse photo"}
                  class="w-full h-full object-cover group-hover:opacity-75 transition-opacity duration-200"
                />
                <%= if photo.is_primary do %>
                  <div class="absolute top-2 left-2">
                    <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                      Primary
                    </span>
                  </div>
                <% end %>
              </div>

              <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                <div class="flex space-x-2">
                  <button
                    phx-click="view_photo"
                    phx-value-id={photo.id}
                    phx-target={@myself}
                    class="bg-white bg-opacity-90 hover:bg-opacity-100 rounded-full p-2 text-gray-700 hover:text-gray-900 transition-colors"
                    title="View photo"
                  >
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                      />
                    </svg>
                  </button>

                  <%= unless photo.is_primary do %>
                    <button
                      phx-click="set_primary"
                      phx-value-id={photo.id}
                      phx-target={@myself}
                      class="bg-white bg-opacity-90 hover:bg-opacity-100 rounded-full p-2 text-gray-700 hover:text-yellow-600 transition-colors"
                      title="Set as primary photo"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"
                        />
                      </svg>
                    </button>
                  <% end %>

                  <button
                    phx-click="delete_photo"
                    phx-value-id={photo.id}
                    phx-target={@myself}
                    data-confirm="Are you sure you want to delete this photo?"
                    class="bg-white bg-opacity-90 hover:bg-opacity-100 rounded-full p-2 text-gray-700 hover:text-red-600 transition-colors"
                    title="Delete photo"
                  >
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                      />
                    </svg>
                  </button>
                </div>
              </div>

              <%= if photo.description do %>
                <p class="mt-2 text-sm text-gray-600 truncate">{photo.description}</p>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{photos: _photos} = assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("view_photo", %{"id" => _id}, socket) do
    # In a full implementation, this could open a modal or navigate to a detailed view
    {:noreply, put_flash(socket, :info, "Photo viewer not implemented yet")}
  end

  @impl true
  def handle_event("set_primary", %{"id" => id}, socket) do
    photo_id = String.to_integer(id)

    case socket.assigns[:team_id] do
      nil ->
        {:noreply, put_flash(socket, :error, "Team information not available")}

      team_id ->
        case Media.set_primary_photo(team_id, photo_id) do
          {:ok, _} ->
            send(self(), :refresh_photos)
            {:noreply, put_flash(socket, :info, "Primary photo updated successfully")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to set primary photo")}
        end
    end
  end

  @impl true
  def handle_event("delete_photo", %{"id" => id}, socket) do
    photo_id = String.to_integer(id)

    case socket.assigns[:team_id] do
      nil ->
        {:noreply, put_flash(socket, :error, "Team information not available")}

      team_id ->
        case Media.delete_photo(team_id, photo_id) do
          {:ok, _} ->
            send(self(), :refresh_photos)
            {:noreply, put_flash(socket, :info, "Photo deleted successfully")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to delete photo")}
        end
    end
  end
end
