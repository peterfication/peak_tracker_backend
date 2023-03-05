# List all available commands
default:
  just --list

# Run the things that are run in CI
ci: spellcheck format graphql-schema-dump lint test

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

# Run the spellchecker
spellcheck:
  yarn spellcheck

# List all unknown words to add them to .cspell.dictionary.txt
spellcheck-list:
  yarn spellcheck:list

# Open an SSH session on fly.io
ssh:
  flyctl ssh console

# Open an SSH session with IEX on fly.io
ssh-iex:
  flyctl ssh console --command "/app/bin/peak_tracker remote"

# Proxy the production database
ssh-proxy-db:
  fly proxy 5433:5432 -a peak-tracker-db

# Restart the application on fly.io
ssh-restart:
  fly apps restart peak-tracker

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
