defmodule Barnkeeper.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Barnkeeper.Media` context.
  """

  alias Barnkeeper.Media

  @doc """
  Generate a photo.
  """
  def photo_fixture(horse, user, attrs \\ %{}) do
    default_attrs = %{
      filename: "test_#{System.unique_integer()}.jpg",
      original_filename: "test.jpg",
      content_type: "image/jpeg",
      file_size: 12345,
      url: "/uploads/test_#{System.unique_integer()}.jpg",
      description: "Test photo",
      is_primary: false,
      horse_id: horse.id,
      uploaded_by_id: user.id
    }

    attrs = Map.merge(default_attrs, attrs)

    {:ok, photo} =
      attrs
      |> Media.create_photo()

    photo
  end
end
