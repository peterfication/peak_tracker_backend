defmodule PeakTrackerWeb.Live.PeakLive.IndexTest do
  use PeakTrackerWeb.ConnCase

  test "lists all peaks", %{conn: conn} do
    conn = get(conn, ~p"/peaks")
    assert html_response(conn, 200) =~ "Peaks"
  end
end
