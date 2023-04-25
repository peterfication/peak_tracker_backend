defmodule PeakTracker.Mountains.Services.Peaks.FetchFromOverpass do
  @moduledoc """
  This module provides a function to fetch mountain peak data from the
  Overpass API within a bounding box specified by two geo locations.

  Each location is represented by a map with `:latitude` and `:longitude` keys.

  The main function returns a list of maps containing the latitude, longitude, osm ID, name, and
  elevation, as well as wikidata ID and wikipedia information of the mountain peaks
  within the bounding box.
  """

  @overpass_url "https://overpass-api.de/api/interpreter"

  alias HTTPoison, as: HttpClient

  @type coordinate :: float()
  @type location :: %{latitude: coordinate, longitude: coordinate}
  @type element :: map()
  @type peak :: %{
          latitude: float(),
          longitude: float(),
          osm_id: integer(),
          name: String.t(),
          elevation: String.t(),
          wikidata_id: String.t(),
          wikipedia: String.t()
        }

  @doc """
  Fetches mountain peak data from the Overpass API within a bounding box
  specified by two geo locations.

  Each location is a map with `:latitude` and `:longitude` keys.

  Returns a list of maps containing the latitude, longitude, osm ID, name, and
  elevation, as well as wikidata ID and wikipedia information of the mountain peaks
  within the bounding box.

  ## Examples

      iex> min_location = %{latitude: 47.3, longitude: 10.8}
      iex> max_location = %{latitude: 47.5, longitude: 11.2}
      iex> {:ok, peaks} = PeakTracker.Mountains.Services.Peaks.FetchFromOverpass.execute(min_location, max_location)
      iex> Enum.count(peaks)
      220
  """
  @spec execute(location, location) :: {:ok, [peak]} | {:error, String.t()}
  def execute(
        %{
          latitude: min_latitude,
          longitude: min_longitude
        },
        %{
          latitude: max_latitude,
          longitude: max_longitude
        }
      ) do
    query = build_query(min_latitude, min_longitude, max_latitude, max_longitude)
    response = execute_query(query)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, decode_result(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Request failed with status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed with reason #{inspect(reason)}"}
    end
  end

  @spec build_query(coordinate, coordinate, coordinate, coordinate) :: String.t()
  defp build_query(min_lat, min_lon, max_lat, max_lon) do
    """
    [out:json];
    (node["natural"="peak"]
    (#{min_lat},#{min_lon},#{max_lat},#{max_lon});
    );
    out body;
    """
  end

  @spec execute_query(String.t()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  defp execute_query(query) do
    http_client = Application.get_env(:peak_tracker, __MODULE__)[:http_client] || HttpClient
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    http_client.post(@overpass_url, query, headers)
  end

  @spec decode_result(String.t()) :: [peak]
  defp decode_result(body) do
    {:ok, decoded} = Jason.decode(body)
    elements = decoded["elements"]

    Enum.map(elements, fn element ->
      %{
        latitude: element["lat"],
        longitude: element["lon"],
        osm_id: element["id"],
        name: Map.get(element["tags"], "name"),
        elevation: Map.get(element["tags"], "ele"),
        wikidata_id: Map.get(element["tags"], "wikidata"),
        wikipedia: Map.get(element["tags"], "wikipedia")
      }
    end)
  end
end
