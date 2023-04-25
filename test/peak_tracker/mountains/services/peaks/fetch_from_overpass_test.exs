defmodule PeakTracker.Mountains.Services.Peaks.FetchFromOverpassTest do
  use ExUnit.Case, async: true
  import Mox

  alias PeakTracker.Mountains.Services.Peaks.FetchFromOverpass

  setup :verify_on_exit!

  test "execute/2 returns mountain peak data within a bounding box" do
    min_location = %{latitude: 40.5, longitude: -105.2}
    max_location = %{latitude: 41.0, longitude: -104.8}

    url = "https://overpass-api.de/api/interpreter"

    query = """
    [out:json];
    (node["natural"="peak"]
    (40.5,-105.2,41.0,-104.8);
    );
    out body;
    """

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    overpass_response = %{
      "elements" => [
        %{
          "id" => 1,
          "lat" => 40.51,
          "lon" => -105.1,
          "tags" => %{
            "ele" => "3500",
            "name" => "Peak 1",
            "natural" => "peak",
            "wikidata" => "Q1",
            "wikipedia" => "en:Peak 1"
          }
        },
        %{
          "id" => 2,
          "lat" => 40.8,
          "lon" => -104.9,
          "tags" => %{
            "ele" => "3700",
            "name" => "Peak 2",
            "natural" => "peak"
          }
        }
      ]
    }

    PeakTracker.HttpClientMock
    |> expect(
      :post,
      fn ^url, ^query, ^headers ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(overpass_response)}}
      end
    )

    {:ok, peaks} = FetchFromOverpass.execute(min_location, max_location)

    assert Enum.count(peaks) == 2

    assert Enum.at(peaks, 0) == %{
             osm_id: 1,
             latitude: 40.51,
             longitude: -105.1,
             name: "Peak 1",
             elevation: "3500",
             wikidata_id: "Q1",
             wikipedia: "en:Peak 1"
           }

    assert Enum.at(peaks, 1) == %{
             osm_id: 2,
             latitude: 40.8,
             longitude: -104.9,
             name: "Peak 2",
             elevation: "3700",
             wikidata_id: nil,
             wikipedia: nil
           }
  end
end
