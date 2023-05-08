defmodule PeakTrackerWeb.GraphQL.Queries.PeakTest do
  use GraphqlIntegrationTest

  test "returns a peak", %{conn: conn} do
    peak = PeakTracker.MountainsFixtures.peak_fixture()

    assert_graphql_request(conn, %{
      request_variables: %{
        id: peak.id
      },
      response_variables: %{
        peak_id: peak.id,
        peak_name: peak.name,
        peak_scale_count: 0
      }
    })
  end
end
