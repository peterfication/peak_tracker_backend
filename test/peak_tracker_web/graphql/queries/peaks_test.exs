defmodule PeakTrackerWeb.GraphQL.Queries.PeaksTest do
  use GraphqlIntegrationTest

  test "returns peaks", %{conn: conn} do
    peak = PeakTracker.MountainsFixtures.peak_fixture()

    assert_graphql_request(conn, %{
      response_variables: %{
        peak_id: peak.id,
        peak_name: peak.name,
        peak_scale_count: 0
      }
    })
  end
end
