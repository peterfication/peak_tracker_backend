%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["mix.exs", "config/", "lib/"],
        excluded: []
      },
      plugins: [],
      requires: [],
      strict: true,
      parse_timeout: 5000,
      color: true,
      checks: [
        {Credo.Check.Design.TagTODO, [exit_status: 0]}
      ]
    }
  ]
}
