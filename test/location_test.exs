defmodule PeakTracker.Mountains.Services.Peaks.ImportTest do
  use ExUnit.Case

  alias Location, as: Subject

  describe "expand_locations/2" do
    test "returns an empty list when the locations are the same" do
      location = %Location{latitude: 1, longitude: 1}

      assert Subject.expand_locations(location, location) == []
    end

    test "returns all combinations of latitude and longitude between two locations" do
      location_a = %Location{latitude: 1, longitude: 1}
      location_b = %Location{latitude: 3, longitude: 3}

      expected_result = [
        %Location{latitude: 1, longitude: 1},
        %Location{latitude: 1, longitude: 2},
        %Location{latitude: 1, longitude: 3},
        %Location{latitude: 2, longitude: 1},
        %Location{latitude: 2, longitude: 2},
        %Location{latitude: 2, longitude: 3},
        %Location{latitude: 3, longitude: 1},
        %Location{latitude: 3, longitude: 2},
        %Location{latitude: 3, longitude: 3}
      ]

      assert Subject.expand_locations(location_a, location_b) == expected_result
    end

    test "returns a single point when the locations have the same latitude or longitude" do
      location_a = %Location{latitude: 1, longitude: 1}
      location_b = %Location{latitude: 1, longitude: 2}
      location_c = %Location{latitude: 2, longitude: 1}

      assert Subject.expand_locations(location_a, location_b) == [
               %Location{latitude: 1, longitude: 1},
               %Location{latitude: 1, longitude: 2}
             ]

      assert Subject.expand_locations(location_a, location_c) == [
               %Location{latitude: 1, longitude: 1},
               %Location{latitude: 2, longitude: 1}
             ]
    end

    test "handles locations with negative coordinates" do
      location_a = %Location{latitude: -2, longitude: -2}
      location_b = %Location{latitude: 1, longitude: 1}

      expected_result = [
        %Location{latitude: -2, longitude: -2},
        %Location{latitude: -2, longitude: -1},
        %Location{latitude: -2, longitude: 0},
        %Location{latitude: -2, longitude: 1},
        %Location{latitude: -1, longitude: -2},
        %Location{latitude: -1, longitude: -1},
        %Location{latitude: -1, longitude: 0},
        %Location{latitude: -1, longitude: 1},
        %Location{latitude: 0, longitude: -2},
        %Location{latitude: 0, longitude: -1},
        %Location{latitude: 0, longitude: 0},
        %Location{latitude: 0, longitude: 1},
        %Location{latitude: 1, longitude: -2},
        %Location{latitude: 1, longitude: -1},
        %Location{latitude: 1, longitude: 0},
        %Location{latitude: 1, longitude: 1}
      ]

      assert Subject.expand_locations(location_a, location_b) == expected_result
    end

    test "truncates decimal values" do
      location_a = %Location{latitude: 1.1, longitude: 1.2}
      location_b = %Location{latitude: 3.4, longitude: 3.6}

      expected_result = [
        %Location{latitude: 1, longitude: 1},
        %Location{latitude: 1, longitude: 2},
        %Location{latitude: 1, longitude: 3},
        %Location{latitude: 2, longitude: 1},
        %Location{latitude: 2, longitude: 2},
        %Location{latitude: 2, longitude: 3},
        %Location{latitude: 3, longitude: 1},
        %Location{latitude: 3, longitude: 2},
        %Location{latitude: 3, longitude: 3}
      ]

      assert Subject.expand_locations(location_a, location_b) == expected_result
    end
  end
end
