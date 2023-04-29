defmodule PeakTrackerWeb.PeakLive.UtilsTest do
  use ExUnit.Case

  alias PeakTrackerWeb.PeakLive.Utils, as: Subject

  test "peak_load/1 when the current user is nil loads only :scale_count" do
    assert Subject.peak_load(nil) == [:scale_count]
  end

  test "peak_load/1 when the current user is present loads also user related data" do
    assert Subject.peak_load(%{id: "some-id"}) == [
             :scale_count,
             scaled_by_user: %{user_id: "some-id"}
           ]
  end
end
