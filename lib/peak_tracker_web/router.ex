defmodule PeakTrackerWeb.Router do
  use PeakTrackerWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PeakTrackerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", PeakTrackerWeb do
    pipe_through :browser

    get "/", PageController, :root

    sign_in_route()
    sign_out_route AuthController
    auth_routes_for PeakTracker.Accounts.User, to: AuthController
    reset_route []

    get "/peaks", PeakController, :index
    get "/peaks/:slug", PeakController, :show
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

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:peak_tracker, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PeakTrackerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
