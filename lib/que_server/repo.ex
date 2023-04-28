defmodule QueServer.Repo do
  use Ecto.Repo,
    otp_app: :que_server,
    adapter: Ecto.Adapters.SQLite3
end
