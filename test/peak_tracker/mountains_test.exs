defmodule PeakTracker.MountainsTest do
  use PeakTracker.DataCase

  import PeakTracker.MountainsFixtures

  alias PeakTracker.Mountains

  describe "list_peaks/0 " do
    test "returns all peaks" do
      peak = peak_fixture()
      assert Enum.map(Mountains.list_peaks(), fn peak -> peak.slug end) == [peak.slug]
    end
  end

  describe "get_peak!/1" do
    test "returns the peak with given slug" do
      peak = peak_fixture()
      assert Mountains.get_peak!(peak.slug).slug == peak.slug
    end

    test "raises an error when there is no peak with given slug" do
      assert_raise Ecto.NoResultsError, fn ->
        Mountains.get_peak!("some-other-slug")
      end
    end
  end

  describe "get_peak/1" do
    test "returns the peak with given slug" do
      peak = peak_fixture()
      assert Mountains.get_peak(peak.slug).slug == peak.slug
    end

    test "returns nil when there is no peak with given slug" do
      assert Mountains.get_peak("some-other-slug") == nil
    end
  end
end
