defmodule TouristApp.Repo do
  use Ecto.Repo,
    otp_app: :tourist_app,
    adapter: Ecto.Adapters.Postgres
end
