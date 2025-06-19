defmodule Barnkeeper.MediaTest do
  use Barnkeeper.DataCase

  import Barnkeeper.{AccountsFixtures, TeamsFixtures, HorsesFixtures, MediaFixtures}

  alias Barnkeeper.Media

  describe "photos" do
    setup do
      user = user_fixture()
      team = team_fixture(user)
      horse = horse_fixture(team)

      %{user: user, team: team, horse: horse}
    end

    test "list_photos/2 returns photos for a horse in a team", %{
      team: team,
      horse: horse,
      user: user
    } do
      photo = photo_fixture(horse, user)

      photos = Media.list_photos(team.id, horse.id)
      assert length(photos) == 1
      assert List.first(photos).id == photo.id
    end

    test "get_photo!/2 returns the photo with given id in team", %{
      team: team,
      horse: horse,
      user: user
    } do
      photo = photo_fixture(horse, user)
      assert Media.get_photo!(team.id, photo.id).id == photo.id
    end

    test "create_photo/1 with valid data creates a photo", %{horse: horse, user: user} do
      valid_attrs = %{
        filename: "test.jpg",
        original_filename: "test.jpg",
        content_type: "image/jpeg",
        file_size: 12345,
        url: "/test.jpg",
        horse_id: horse.id,
        uploaded_by_id: user.id
      }

      assert {:ok, %Media.Photo{} = photo} = Media.create_photo(valid_attrs)
      assert photo.filename == "test.jpg"
      assert photo.original_filename == "test.jpg"
      assert photo.content_type == "image/jpeg"
      assert photo.file_size == 12345
      assert photo.url == "/test.jpg"
    end

    test "create_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_photo(%{})
    end

    test "update_photo/2 with valid data updates the photo", %{horse: horse, user: user} do
      photo = photo_fixture(horse, user)
      update_attrs = %{description: "Updated description"}

      assert {:ok, %Media.Photo{} = photo} = Media.update_photo(photo, update_attrs)
      assert photo.description == "Updated description"
    end

    test "delete_photo/1 deletes the photo", %{team: team, horse: horse, user: user} do
      photo = photo_fixture(horse, user)
      assert {:ok, %Media.Photo{}} = Media.delete_photo(team.id, photo.id)
      assert_raise Ecto.NoResultsError, fn -> Media.get_photo!(team.id, photo.id) end
    end

    test "set_primary_photo/2 sets photo as primary and unsets others", %{
      team: team,
      horse: horse,
      user: user
    } do
      photo1 = photo_fixture(horse, user, %{is_primary: true})
      photo2 = photo_fixture(horse, user, %{is_primary: false})

      assert {:ok, {1, _}} = Media.set_primary_photo(team.id, photo2.id)

      updated_photo1 = Media.get_photo!(team.id, photo1.id)
      updated_photo2 = Media.get_photo!(team.id, photo2.id)

      assert updated_photo1.is_primary == false
      assert updated_photo2.is_primary == true
    end

    test "get_primary_photo/2 returns the primary photo for a horse", %{
      team: team,
      horse: horse,
      user: user
    } do
      _photo1 = photo_fixture(horse, user, %{is_primary: false})
      photo2 = photo_fixture(horse, user, %{is_primary: true})

      primary_photo = Media.get_primary_photo(team.id, horse.id)
      assert primary_photo.id == photo2.id
      assert primary_photo.is_primary == true
    end
  end
end
