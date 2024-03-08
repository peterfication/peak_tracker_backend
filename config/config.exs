# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :peak_tracker, ecto_repos: [PeakTracker.Repo]
config :peak_tracker, :ash_apis, [PeakTracker.Mountains, PeakTracker.Accounts]

if Mix.env() != :test do
  # See https://ash-hq.org/docs/guides/ash/latest/tutorials/get-started#temporary-config
  config :ash, :use_all_identities_in_manage_relationship?, false
end

# Configures the endpoint
config :peak_tracker, PeakTrackerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [
      json: PeakTrackerWeb.ErrorJSON,
      html: PeakTrackerWeb.ErrorHTML
    ],
    layout: false
  ],
  pubsub_server: PeakTracker.PubSub,
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT") || "zwUZhP5h"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :peak_tracker, PeakTracker.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Set Sentry to none, so it is disabled by default and only enabled per environment
config :sentry, environment_name: Mix.env()

config :peak_tracker, PeakTracker.Mountains,
  graphql: [
    show_raised_errors?: true
  ]

config :peak_tracker, PeakTracker.Accounts,
  graphql: [
    show_raised_errors?: true
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
