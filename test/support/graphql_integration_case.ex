defmodule GraphqlIntegrationCase do
  defmacro __using__(_options) do
    quote do
      # TODO: Extract this into an option
      # See https://blog.codeminer42.com/how-to-test-shared-behavior-in-elixir-3ea3ebb92b64/
      use PeakTrackerWeb.ConnCase

      setup %{conn: conn} = context do
        if context[:actor] do
          actor = PeakTracker.AccountsFixtures.user_fixture()

          %{
            conn: conn |> Ash.PlugHelpers.set_actor(actor),
            actor: actor
          }
        else
          %{conn: conn}
        end
      end

      def assert_graphql_request(conn, options \\ %{}),
        do: assert(execute_graphql_query(conn, options) == load_json_response(options))

      def execute_graphql_query(conn, options),
        do:
          post(
            conn,
            ~p"/gql",
            %{
              query: load_query(),
              variables: options[:request_variables] || %{}
            }
          )
          |> json_response(200)

      defp load_query,
        do:
          File.read!(
            Path.expand(
              "#{file_name_without_extension()}/request.graphql",
              Path.dirname(__ENV__.file)
            )
          )

      defp file_name_without_extension, do: Path.basename(__ENV__.file) |> Path.rootname()

      defp load_json_response(options = %{}),
        do: Jason.decode!(response_string_with_variables(options))

      defp response_string_with_variables(options),
        do:
          Enum.reduce(
            response_replacements(options),
            load_response_string(options),
            fn {old, new}, acc ->
              String.replace(acc, old, new)
            end
          )

      defp response_replacements(options),
        do:
          Enum.map(Map.to_list(options[:response_variables] || %{}), fn {key, value} ->
            case value do
              value when is_number(value) -> {"\"{{#{key}}}\"", "#{value}"}
              _ -> {"{{#{key}}}", value}
            end
          end)

      defp load_response_string(options),
        do:
          Path.expand(
            options[:response_template_file_path] ||
              "#{file_name_without_extension()}/response.json",
            Path.dirname(__ENV__.file)
          )
          |> File.read!()
    end
  end
end
