defmodule PeakTracker.Repo do
  use Ecto.Repo,
    otp_app: :peak_tracker,
    adapter: Ecto.Adapters.Postgres
end
