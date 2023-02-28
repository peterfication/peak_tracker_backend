# List all available commands
default:
  just --list

# Run the things that are run in CI
ci: format graphql-schema-dump lint test

# Create the database
db-create:
  mix ash_postgres.create

# Migrate the database
db-migrate:
  mix ash_postgres.migrate

# Format all files
format:
  mix format && yarn format

# Dump the current version of the GraphQL schema
graphql-schema-dump:
  mix absinthe.schema.sdl --schema PeakTracker.Schema

# Lint Elixir files with credo
lint:
  mix credo --strict

# Setup the dependencies and the database
setup:
  mix setup

# Start the Phoenix server
start:
  mix phx.server

# Start the Phoenix server with a REPL
starti:
  iex -S mix phx.server

# Run the tests
test:
  mix test
