defmodule PeakTrackerWeb.Router do
  use PeakTrackerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PeakTrackerWeb do
    pipe_through :api
  end

  scope "/" do
    forward "/gql", Absinthe.Plug, schema: PeakTracker.Schema

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: PeakTracker.Schema,
            interface: :playground
  end
end
