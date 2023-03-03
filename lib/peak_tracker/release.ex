defmodule PeakTracker.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :peak_tracker

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  # Seed the database
  def seed do
    start_app()

    seeds_file_path = Path.join(Application.app_dir(@app, "priv"), "repo/seeds.exs")

    IO.puts("Seeding the database from #{seeds_file_path} ...")
    Code.eval_file(seeds_file_path)
    IO.puts("Database seeded.")
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp start_app do
    IO.puts("Starting the app ...")
    load_app()

    Application.ensure_all_started(@app)
    IO.puts("App started.")
  end

  defp load_app do
    Application.load(@app)
  end
end
