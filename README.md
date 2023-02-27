# PeakTracker Backend

This is the backend for PeakTracker which is a project for me to learn Elixir.

It's built with [Phoenix](https://www.phoenixframework.org/) and [Ash](https://ash-hq.org).

## Useful commands:

- `mix deps.get`: Install the dependencies
- `mix ash_postgres.create`: Create the database
- `mix ash_postgres.migrate`: Migrate the database
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  - Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Create a peak

```elixir
PeakTracker.Mountains.Peak
|> Ash.Changeset.for_create(:create, %{name: "Wendelstein"})
|> PeakTracker.Mountains.create!()
```
