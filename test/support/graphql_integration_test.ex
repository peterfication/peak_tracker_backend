defmodule GraphqlIntegrationTest do
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
        do: assert(execute_graphql_query(conn) == load_json_response(options))

      def execute_graphql_query(conn) do
        conn =
          post(
            conn,
            ~p"/gql",
            %{query: load_query()}
          )

        json_response(conn, 200)
      end

      def load_query,
        do:
          File.read!(
            Path.expand(
              "#{file_name_without_extension()}/request.graphql",
              Path.dirname(__ENV__.file)
            )
          )

      def file_name_without_extension, do: Path.basename(__ENV__.file) |> Path.rootname()

      def load_json_response(options = %{}) do
        variables = options[:response_variables] || %{}
        replacements = Enum.map(Map.to_list(variables), fn {k, v} -> {"{{#{k}}}", v} end)

        response_string_with_variables =
          Enum.reduce(replacements, load_response_string(options), fn {old, new}, acc ->
            String.replace(acc, old, new)
          end)

        Jason.decode!(response_string_with_variables)
      end

      def load_response_string(options) do
        response_file_path =
          Path.expand(
            options[:response_template_file_path] ||
              "#{file_name_without_extension()}/response.json",
            Path.dirname(__ENV__.file)
          )

        File.read!(response_file_path)
      end
    end
  end
end
