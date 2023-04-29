defmodule PeakTrackerWeb.Live.PeakLive.ShowTest do
  use PeakTrackerWeb.ConnCase

  import PeakTracker.MountainsFixtures

  describe "show peak" do
    setup [:create_peak]

    test "when there is a peak, shows a single peak", %{conn: conn, peak: peak} do
      conn = get(conn, ~p"/peaks/#{peak.slug}")
      assert html_response(conn, 200) =~ peak.name
    end

    test "when there is no peak, returns a 404", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, ~p"/peaks/does-not-exist")
      end
    end
  end

  defp create_peak(_) do
    peak = peak_fixture()
    %{peak: peak}
  end
end
