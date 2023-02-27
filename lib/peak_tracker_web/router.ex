defmodule PeakTrackerWeb.Router do
  use PeakTrackerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PeakTrackerWeb do
    pipe_through :api
  end
end
