[
  import_deps: [
    :ash,
    :ash_authentication,
    :ash_authentication_phoenix,
    :ash_postgres,
    :ecto,
    :ecto_sql,
    :phoenix,
    :type_check
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs"
  ]
]
