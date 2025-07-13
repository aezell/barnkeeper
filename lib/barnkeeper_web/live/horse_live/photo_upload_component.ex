defmodule BarnkeeperWeb.HorseLive.PhotoUploadComponent do
  @moduledoc """
  Photo upload component for horses using Phoenix LiveView uploads.
  """
  use BarnkeeperWeb, :live_component

  alias Barnkeeper.Media
  alias Barnkeeper.Media.S3Uploader

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:photos,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 10,
       # 10MB
       max_file_size: 10_000_000,
       auto_upload: true,
       progress: &handle_progress/3
     )}
  end

  @impl true
  def update(%{horse: _horse, current_user: _current_user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Media.change_photo(%Media.Photo{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Upload Photos
        <:subtitle>Add photos to {@horse.name}'s album</:subtitle>
      </.header>

      <.simple_form
        for={@changeset}
        id="photo-upload-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <!-- File Upload Area -->
        <div class="space-y-4">
          <div
            phx-drop-target={@uploads.photos.ref}
            class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-gray-400 transition-colors"
          >
            <svg
              class="mx-auto h-12 w-12 text-gray-400"
              stroke="currentColor"
              fill="none"
              viewBox="0 0 48 48"
            >
              <path
                d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              />
            </svg>
            <div class="mt-4">
              <label for={@uploads.photos.ref} class="cursor-pointer">
                <span class="text-base font-medium text-gray-900">Upload photos</span>
                <span class="text-gray-500"> or drag and drop</span>
              </label>
              <.live_file_input upload={@uploads.photos} class="sr-only" />
            </div>
            <p class="text-xs text-gray-500 mt-2">PNG, JPG, GIF, WebP up to 10MB each</p>
          </div>
          
    <!-- Upload Progress -->
          <%= for entry <- @uploads.photos.entries do %>
            <div class="bg-gray-50 rounded-lg p-4">
              <div class="flex items-center justify-between">
                <div class="flex items-center space-x-3">
                  <div class="flex-shrink-0">
                    <.live_img_preview entry={entry} class="h-10 w-10 rounded object-cover" />
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="text-sm font-medium text-gray-900 truncate">{entry.client_name}</p>
                    <p class="text-sm text-gray-500">{format_file_size(entry.client_size)}</p>
                  </div>
                </div>
                <div class="flex items-center space-x-2">
                  <%= if entry.progress < 100 do %>
                    <div class="w-32 bg-gray-200 rounded-full h-2">
                      <div
                        class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                        style={"width: #{entry.progress}%"}
                      >
                      </div>
                    </div>
                    <span class="text-sm text-gray-500">{entry.progress}%</span>
                  <% else %>
                    <span class="text-sm text-green-600 font-medium">Complete</span>
                  <% end %>
                  <button
                    type="button"
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    phx-target={@myself}
                    class="text-gray-400 hover:text-gray-600"
                  >
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M6 18L18 6M6 6l12 12"
                      />
                    </svg>
                  </button>
                </div>
              </div>
              
    <!-- Upload Errors -->
              <%= for err <- upload_errors(@uploads.photos, entry) do %>
                <p class="mt-2 text-sm text-red-600">
                  {error_to_string(err)}
                </p>
              <% end %>
            </div>
          <% end %>
          
    <!-- General Upload Errors -->
          <%= for err <- upload_errors(@uploads.photos) do %>
            <div class="bg-red-50 border border-red-200 rounded-md p-4">
              <p class="text-sm text-red-600">
                {error_to_string(err)}
              </p>
            </div>
          <% end %>
        </div>

        <:actions>
          <.button
            phx-disable-with="Uploading..."
            disabled={@uploads.photos.entries == []}
            class="w-full"
          >
            Upload Photos
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    horse = socket.assigns.horse
    current_user = socket.assigns.current_user

    uploaded_files =
      consume_uploaded_entries(socket, :photos, fn %{path: path}, entry ->
        # Generate unique S3 key
        s3_key = S3Uploader.generate_key(horse.id, entry.client_name)

        # Upload to S3
        case S3Uploader.upload_file(path, s3_key, entry.client_type) do
          {:ok, s3_url} ->
            # Create photo record with S3 URL
            photo_attrs = %{
              filename: s3_key,
              original_filename: entry.client_name,
              content_type: entry.client_type,
              file_size: entry.client_size,
              url: s3_url,
              horse_id: horse.id,
              uploaded_by_id: current_user.id
            }

            case Media.create_photo(photo_attrs) do
              {:ok, photo} -> photo
              {:error, _changeset} -> {:error, "Failed to save photo record"}
            end

          {:error, reason} ->
            {:error, "S3 upload failed: #{inspect(reason)}"}
        end
      end)

    # Handle the results - uploaded_files is a list of either Photo struct or {:error, reason}
    successful_uploads =
      Enum.count(uploaded_files, fn
        %Barnkeeper.Media.Photo{} -> true
        _ -> false
      end)

    failed_uploads = Enum.count(uploaded_files, &match?({:error, _}, &1))

    cond do
      successful_uploads > 0 and failed_uploads == 0 ->
        notify_parent({:uploaded, successful_uploads})
        {:noreply, socket}

      successful_uploads > 0 and failed_uploads > 0 ->
        notify_parent({:uploaded, successful_uploads})
        {:noreply, socket}

      failed_uploads > 0 ->
        error_messages =
          uploaded_files
          |> Enum.filter(&match?({:error, _}, &1))
          |> Enum.map(fn {:error, msg} -> msg end)
          |> Enum.join(", ")

        {:noreply,
         socket
         |> put_flash(:error, "Upload failed: #{error_messages}")}

      true ->
        {:noreply,
         socket
         |> put_flash(:error, "No files selected for upload")}
    end
  end

  def handle_progress(:photos, entry, socket) do
    if entry.done? do
      # File upload completed
      {:noreply, socket}
    else
      # Upload in progress
      {:noreply, socket}
    end
  end

  defp format_file_size(size) when is_integer(size) do
    cond do
      size < 1024 -> "#{size} B"
      size < 1024 * 1024 -> "#{Float.round(size / 1024, 1)} KB"
      true -> "#{Float.round(size / (1024 * 1024), 1)} MB"
    end
  end

  defp error_to_string(:too_large), do: "File too large"
  defp error_to_string(:too_many_files), do: "Too many files"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(error), do: "Upload error: #{inspect(error)}"

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
