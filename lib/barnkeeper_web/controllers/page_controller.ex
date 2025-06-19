defmodule BarnkeeperWeb.PageController do
  use BarnkeeperWeb, :controller

  def home(conn, _params) do
    # Use the app layout to show the navbar
    render(conn, :home)
  end
end
