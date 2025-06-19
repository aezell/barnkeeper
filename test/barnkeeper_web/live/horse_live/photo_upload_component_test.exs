defmodule BarnkeeperWeb.HorseLive.PhotoUploadComponentTest do
  use BarnkeeperWeb.ConnCase

  import Barnkeeper.{AccountsFixtures, TeamsFixtures, HorsesFixtures}

  alias BarnkeeperWeb.HorseLive.PhotoUploadComponent

  defp create_horse(_) do
    user = user_fixture()
    team = team_fixture(user)
    horse = horse_fixture(team)
    %{user: user, team: team, horse: horse}
  end

  describe "PhotoUploadComponent" do
    setup [:create_horse]

    test "handle_progress returns correct format for upload in progress", %{
      horse: horse,
      user: user
    } do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          horse: horse,
          current_user: user
        }
      }

      # Create a mock upload entry that's not done
      entry = %Phoenix.LiveView.UploadEntry{
        done?: false,
        progress: 50
      }

      # Call handle_progress and ensure it returns the correct format
      result = PhotoUploadComponent.handle_progress(:photos, entry, socket)

      # Should return {:noreply, socket} tuple, not just socket
      assert {:noreply, %Phoenix.LiveView.Socket{}} = result
    end

    test "handle_progress returns correct format for completed upload", %{
      horse: horse,
      user: user
    } do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          horse: horse,
          current_user: user
        }
      }

      # Create a mock upload entry that's done
      entry = %Phoenix.LiveView.UploadEntry{
        done?: true,
        progress: 100
      }

      # Call handle_progress and ensure it returns the correct format
      result = PhotoUploadComponent.handle_progress(:photos, entry, socket)

      # Should return {:noreply, socket} tuple, not just socket
      assert {:noreply, %Phoenix.LiveView.Socket{}} = result
    end
  end
end
