# List all available commands
default:
  just --list

# Run the things that are run in CI
ci: format graphql-schema-dump lint test

# Migrate the dev database
db-migrate:
  mix ash_postgres.migrate

# Drop and recreate and seed the database
db-reset:
  mix ecto.reset

# Seed the dev database
db-seed:
  mix ecto.seed

# Format all files
format:
  mix format && yarn format

# Dump the current version of the GraphQL schema
graphql-schema-dump:
  mix absinthe.schema.sdl --schema PeakTracker.Schema

# Lint Elixir files with credo and Javascript files with ESLint
lint:
  yarn lint && mix credo --strict

# Build the application in dev mode
release-dev:
  mix release

# Build the application in prod mode
release-prod:
  MIX_ENV=prod mix release

# Setup the dependencies, the database and the assets
setup:
  mix setup

# Open an SSH session on fly.io
ssh:
  flyctl ssh console

# Open an SSH session with IEX on fly.io
ssh-iex:
  flyctl ssh console --command "/app/bin/peak_tracker remote"

# Start the Phoenix server
start:
  mix phx.server

# Start the Phoenix server with a REPL
start-interactive:
  iex -S mix phx.server

alias starti := start-interactive

# Run the tests
test:
  mix test
