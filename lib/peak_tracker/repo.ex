defmodule PeakTracker.Repo do
  use AshPostgres.Repo, otp_app: :peak_tracker

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
