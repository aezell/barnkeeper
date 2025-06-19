defmodule Barnkeeper.Repo do
  use Ecto.Repo,
    otp_app: :barnkeeper,
    adapter: Ecto.Adapters.Postgres
end
