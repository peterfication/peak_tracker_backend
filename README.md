# PeakTracker Backend

This is the backend for PeakTracker which is a project for me to learn Elixir.

It's built with [Phoenix](https://www.phoenixframework.org/) and [Ash](https://ash-hq.org).

## Useful commands

Commands are defined in the [`Justfile`](Justfile) and can be listed with [`just`](https://github.com/casey/just).

### Create a peak

```elixir
PeakTracker.Mountains.Peak
|> Ash.Changeset.for_create(:create, %{name: "Zugspitze"})
|> PeakTracker.Mountains.create!()
```
