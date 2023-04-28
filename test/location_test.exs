defmodule LocationTest do
  use ExUnit.Case
  use TypeCheck.ExUnit

  alias Location, as: Subject

  spectest(Location, except: [min_max_longitude_and_latitude: 1])

  describe "expand_locations/2" do
    test "when the truncated locations are the same returns a list with only one bounding box" do
      location_a = %Location{latitude: 1, longitude: 1}
      location_b = %Location{latitude: 1.1, longitude: 1.1}

      assert Subject.expand_locations({location_a, location_b}) == [
               {location_a, Location.add_one_degree(location_a) |> elem(1)}
             ]
    end

    test "returns all combinations of latitude and longitude between two locations" do
      location_a = %Location{latitude: 1, longitude: 1}
      location_b = %Location{latitude: 3, longitude: 3}

      expected_result = [
        {%Location{latitude: 1, longitude: 1}, %Location{latitude: 2, longitude: 2}},
        {%Location{latitude: 1, longitude: 2}, %Location{latitude: 2, longitude: 3}},
        {%Location{latitude: 2, longitude: 1}, %Location{latitude: 3, longitude: 2}},
        {%Location{latitude: 2, longitude: 2}, %Location{latitude: 3, longitude: 3}}
      ]

      assert Subject.expand_locations({location_a, location_b}) == expected_result
    end

    test "returns the correct bounding boxes when the input bounding box is not sorted" do
      location_b = %Location{latitude: 1, longitude: 3}
      location_a = %Location{latitude: 3, longitude: 1}

      expected_result = [
        {%Location{latitude: 1, longitude: 1}, %Location{latitude: 2, longitude: 2}},
        {%Location{latitude: 1, longitude: 2}, %Location{latitude: 2, longitude: 3}},
        {%Location{latitude: 2, longitude: 1}, %Location{latitude: 3, longitude: 2}},
        {%Location{latitude: 2, longitude: 2}, %Location{latitude: 3, longitude: 3}}
      ]

      assert Subject.expand_locations({location_a, location_b}) == expected_result
    end

    test "when the locations have the same latitude or longitude returns the correct boxes" do
      location_a = %Location{latitude: 1, longitude: 1}
      location_b = %Location{latitude: 1, longitude: 2}

      assert Subject.expand_locations({location_a, location_b}) == [
               {
                 %Location{latitude: 1, longitude: 1},
                 %Location{latitude: 2, longitude: 2}
               }
             ]

      location_a = %Location{latitude: 1, longitude: 1}
      location_b = %Location{latitude: 1, longitude: 3}

      assert Subject.expand_locations({location_a, location_b}) == [
               {
                 %Location{latitude: 1, longitude: 1},
                 %Location{latitude: 2, longitude: 2}
               },
               {
                 %Location{latitude: 1, longitude: 2},
                 %Location{latitude: 2, longitude: 3}
               }
             ]
    end

    test "handles locations with negative coordinates" do
      location_a = %Location{latitude: -2, longitude: -2}
      location_b = %Location{latitude: 1, longitude: 1}

      expected_result = [
        {%Location{latitude: -2, longitude: -2}, %Location{latitude: -1, longitude: -1}},
        {%Location{latitude: -2, longitude: -1}, %Location{latitude: -1, longitude: 0}},
        {%Location{latitude: -2, longitude: 0}, %Location{latitude: -1, longitude: 1}},
        {%Location{latitude: -1, longitude: -2}, %Location{latitude: 0, longitude: -1}},
        {%Location{latitude: -1, longitude: -1}, %Location{latitude: 0, longitude: 0}},
        {%Location{latitude: -1, longitude: 0}, %Location{latitude: 0, longitude: 1}},
        {%Location{latitude: 0, longitude: -2}, %Location{latitude: 1, longitude: -1}},
        {%Location{latitude: 0, longitude: -1}, %Location{latitude: 1, longitude: 0}},
        {%Location{latitude: 0, longitude: 0}, %Location{latitude: 1, longitude: 1}}
      ]

      assert Subject.expand_locations({location_a, location_b}) == expected_result
    end

    test "truncates decimal values" do
      location_a = %Location{latitude: 1.1, longitude: 1.2}
      location_b = %Location{latitude: 3.4, longitude: 3.6}

      expected_result = [
        {%Location{latitude: 1, longitude: 1}, %Location{latitude: 2, longitude: 2}},
        {%Location{latitude: 1, longitude: 2}, %Location{latitude: 2, longitude: 3}},
        {%Location{latitude: 2, longitude: 1}, %Location{latitude: 3, longitude: 2}},
        {%Location{latitude: 2, longitude: 2}, %Location{latitude: 3, longitude: 3}}
      ]

      assert Subject.expand_locations({location_a, location_b}) == expected_result
    end
  end

  describe "truncate_location/1" do
    test "truncates positive latitude and longitude to whole degrees" do
      location = %Location{latitude: 51.5074, longitude: 0.1278}
      result = Subject.truncate_location(location) |> elem(1)
      assert result.latitude == 51
      assert result.longitude == 0
    end

    test "truncates negative latitude and longitude to whole degrees" do
      location = %Location{latitude: -51.5074, longitude: -0.1278}
      result = Subject.truncate_location(location) |> elem(1)
      assert result.latitude == -51
      assert result.longitude == 0
    end

    test "truncates positive latitude and negative longitude to whole degrees" do
      location = %Location{latitude: 51.5074, longitude: -0.1278}
      result = Subject.truncate_location(location) |> elem(1)
      assert result.latitude == 51
      assert result.longitude == 0
    end

    test "truncates negative latitude and positive longitude to whole degrees" do
      location = %Location{latitude: -51.5074, longitude: 0.1278}
      result = Subject.truncate_location(location) |> elem(1)
      assert result.latitude == -51
      assert result.longitude == 0
    end

    test "returns the same values when already at whole degrees" do
      location = %Location{latitude: 51, longitude: 0}
      result = Subject.truncate_location(location) |> elem(1)
      assert result.latitude == 51
      assert result.longitude == 0
    end
  end

  describe "equals/2" do
    test "returns true when locations have the same latitude and longitude" do
      location_a = %Location{latitude: 51.5074, longitude: 0.1278}
      location_b = %Location{latitude: 51.5074, longitude: 0.1278}
      assert Subject.equals(location_a, location_b) == true
    end

    test "returns false when locations have different latitudes" do
      location_a = %Location{latitude: 51.5074, longitude: 0.1278}
      location_b = %Location{latitude: 52.5074, longitude: 0.1278}
      assert Subject.equals(location_a, location_b) == false
    end

    test "returns false when locations have different longitudes" do
      location_a = %Location{latitude: 51.5074, longitude: 0.1278}
      location_b = %Location{latitude: 51.5074, longitude: 1.1278}
      assert Subject.equals(location_a, location_b) == false
    end

    test "returns false when locations have different latitudes and longitudes" do
      location_a = %Location{latitude: 51.5074, longitude: 0.1278}
      location_b = %Location{latitude: 52.5074, longitude: 1.1278}
      assert Subject.equals(location_a, location_b) == false
    end

    test "returns true when locations are at whole degrees and have the same values" do
      location_a = %Location{latitude: 51, longitude: 0}
      location_b = %Location{latitude: 51, longitude: 0}
      assert Subject.equals(location_a, location_b) == true
    end
  end
end
