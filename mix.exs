defmodule PeakTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :peak_tracker,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [
        tool: ExCoveralls,
        summary: [
          threshold: 20
        ]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.json": :test,
        "coveralls.html": :test
      ],
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.

  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PeakTracker.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Project dependencies.
  # Install them with "mix deps.get"
  defp deps do
    [
      {:absinthe_plug, "~> 1.5"},
      {:ash, "~> 2.9.1"},
      {:ash_authentication, "~> 3.11.1"},
      {:ash_authentication_phoenix, "~> 1.7.0", override: true},
      {:ash_graphql, "~> 0.25.0"},
      {:ash_postgres, "~> 1.3.6"},
      {:bcrypt_elixir, "~> 3.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:finch, "~> 0.13"},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.20"},
      {:hackney, "~> 1.8"},
      {:heroicons, "~> 0.5"},
      {:httpoison, "~> 2.1"},
      {:jason, "~> 1.2"},
      {:mock, "~> 0.3", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:sentry, "~> 8.0"},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:type_check, "~> 0.13.3"}
    ]
  end

  # Mix aliases eg "mix setup"
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ash_postgres.create", "ash_postgres.migrate", "run priv/repo/seeds.exs"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      sentry_recompile: ["compile", "deps.compile sentry --force"]
    ]
  end
end
