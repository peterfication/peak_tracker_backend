ci:
	make format && make graphql-schema-dump && make lint && mix test

format:
	yarn format

graphql-schema-dump:
	mix absinthe.schema.sdl --schema PeakTracker.Schema

lint:
	mix credo --strict

migrate:
	mix ash_postgres.migrate && make format

test:
	mix test
