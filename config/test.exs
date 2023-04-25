import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :peak_tracker, PeakTracker.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "peak_tracker_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :peak_tracker, PeakTrackerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "FdI/c4TBlCWYrWH/AQ/9ElzE/XOW0BL874oiIB+lzHPxjY8HWOsAhe+6GBjVEyK7",
  server: false

# In test we don't send emails.
config :peak_tracker, PeakTracker.Mailer, adapter: Swoosh.Adapters.Test

config :peak_tracker, PeakTracker.Mountains.Services.Peaks.FetchFromOverpass,
  http_client: PeakTracker.HttpClientMock

config :mox, global: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
