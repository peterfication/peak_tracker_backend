defmodule PeakTrackerWeb.GraphQL.Queries.CurrentUserTest do
  use GraphqlIntegrationTest

  describe "when the actor is not set" do
    test "the current user returns nil", %{conn: conn} do
      assert_graphql_request(conn, %{
        response_template_file_path: "current_user_test/response_nil.json"
      })
    end
  end

  describe "when the actor is set" do
    @tag actor: true
    test "the current user returns the actor", %{conn: conn, actor: actor} do
      assert_graphql_request(conn, %{
        response_variables: %{
          user_id: actor.id
        }
      })
    end
  end
end
