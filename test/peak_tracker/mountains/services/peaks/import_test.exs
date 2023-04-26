defmodule PeakTracker.Mountains.Services.Peaks.ImportTest do
  use ExUnit.Case

  alias PeakTracker.Mountains.Services.Peaks.Import, as: Subject

  defstruct Location: [latitude: 0, longitude: 0]

  describe "expand_locations/2" do
    test "returns an empty list when the locations are the same" do
      location = %{latitude: 1, longitude: 1}

      assert Subject.expand_locations(location, location) == []
    end

    test "returns all combinations of latitude and longitude between two locations" do
      location_a = %{latitude: 1, longitude: 1}
      location_b = %{latitude: 3, longitude: 3}

      expected_result = [
        %{latitude: 1, longitude: 1},
        %{latitude: 1, longitude: 2},
        %{latitude: 1, longitude: 3},
        %{latitude: 2, longitude: 1},
        %{latitude: 2, longitude: 2},
        %{latitude: 2, longitude: 3},
        %{latitude: 3, longitude: 1},
        %{latitude: 3, longitude: 2},
        %{latitude: 3, longitude: 3}
      ]

      assert Subject.expand_locations(location_a, location_b) == expected_result
    end

    test "returns a single point when the locations have the same latitude or longitude" do
      location_a = %{latitude: 1, longitude: 1}
      location_b = %{latitude: 1, longitude: 2}
      location_c = %{latitude: 2, longitude: 1}

      assert Subject.expand_locations(location_a, location_b) == [
               %{latitude: 1, longitude: 1},
               %{latitude: 1, longitude: 2}
             ]

      assert Subject.expand_locations(location_a, location_c) == [
               %{latitude: 1, longitude: 1},
               %{latitude: 2, longitude: 1}
             ]
    end

    test "handles locations with negative coordinates" do
      location_a = %{latitude: -2, longitude: -2}
      location_b = %{latitude: 1, longitude: 1}

      expected_result = [
        %{latitude: -2, longitude: -2},
        %{latitude: -2, longitude: -1},
        %{latitude: -2, longitude: 0},
        %{latitude: -2, longitude: 1},
        %{latitude: -1, longitude: -2},
        %{latitude: -1, longitude: -1},
        %{latitude: -1, longitude: 0},
        %{latitude: -1, longitude: 1},
        %{latitude: 0, longitude: -2},
        %{latitude: 0, longitude: -1},
        %{latitude: 0, longitude: 0},
        %{latitude: 0, longitude: 1},
        %{latitude: 1, longitude: -2},
        %{latitude: 1, longitude: -1},
        %{latitude: 1, longitude: 0},
        %{latitude: 1, longitude: 1}
      ]

      assert Subject.expand_locations(location_a, location_b) == expected_result
    end

    test "truncates decimal values" do
      location_a = %{latitude: 1.1, longitude: 1.2}
      location_b = %{latitude: 3.4, longitude: 3.6}

      expected_result = [
        %{latitude: 1, longitude: 1},
        %{latitude: 1, longitude: 2},
        %{latitude: 1, longitude: 3},
        %{latitude: 2, longitude: 1},
        %{latitude: 2, longitude: 2},
        %{latitude: 2, longitude: 3},
        %{latitude: 3, longitude: 1},
        %{latitude: 3, longitude: 2},
        %{latitude: 3, longitude: 3}
      ]

      assert Subject.expand_locations(location_a, location_b) == expected_result
    end
  end
end
