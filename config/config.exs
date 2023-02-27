# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# See https://ash-hq.org/docs/guides/ash/latest/tutorials/get-started#temporary-config
config :ash, :use_all_identities_in_manage_relationship?, false

config :peak_tracker, ecto_repos: [PeakTracker.Repo]
config :peak_tracker, :ash_apis, [PeakTracker.Mountains]

# Configures the endpoint
config :peak_tracker, PeakTrackerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: PeakTrackerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PeakTracker.PubSub,
  live_view: [signing_salt: "zwUZhP5h"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
