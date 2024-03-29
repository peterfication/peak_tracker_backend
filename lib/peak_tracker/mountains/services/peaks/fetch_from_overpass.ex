defmodule PeakTracker.Mountains.Services.Peaks.FetchFromOverpass do
  @moduledoc """
  This module provides a function to fetch mountain peak data from the
  Overpass API within a bounding box specified by two geo locations.

  Each location is represented by a map with `:latitude` and `:longitude` keys.

  The main function returns a list of maps containing the latitude, longitude, osm ID, name, and
  elevation, as well as wikidata ID and wikipedia information of the mountain peaks
  within the bounding box.
  """

  use TypeCheck

  @overpass_url "https://overpass-api.de/api/interpreter"

  alias HTTPoison, as: HttpClient

  @type! coordinate :: Location.coordinate()
  @type! bounding_box :: Location.bounding_box()
  @type! element :: map()
  @type! peak_data :: %{
           latitude: float(),
           longitude: float(),
           osm_id: integer(),
           name: String.t(),
           elevation: integer(),
           wikidata_id: String.t() | nil,
           wikipedia: String.t() | nil
         }

  @doc """
  Fetches mountain peak data from the Overpass API within a bounding box
  specified by two geo locations.

  Each location is a map with `:latitude` and `:longitude` keys.

  Returns a list of maps containing the latitude, longitude, osm ID, name, and
  elevation, as well as wikidata ID and wikipedia information of the mountain peaks
  within the bounding box.

  Peaks without an elevation or without a name are filtered out.

  ## Examples

      iex> location_a = %{latitude: 47.3, longitude: 10.8}
      iex> location_b = %{latitude: 47.5, longitude: 11.2}
      iex> {:ok, peaks} = PeakTracker.Mountains.Services.Peaks.FetchFromOverpass.execute(location_a, location_b)
      iex> Enum.count(peaks)
      220
  """
  @spec! execute(bounding_box()) :: {:ok, [peak_data()]} | {:error, String.t()}
  def execute(bounding_box) do
    query = build_query(bounding_box)
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

  @spec! build_query(bounding_box()) :: String.t()
  defp build_query({location_a, location_b}) do
    """
    [out:json];
    (node["natural"="peak"]
    (#{location_a.latitude},#{location_a.longitude},#{location_b.latitude},#{location_b.longitude});
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

  @spec! decode_result(String.t()) :: [peak_data()]
  defp decode_result(body) do
    {:ok, decoded} = Jason.decode(body)
    elements = decoded["elements"]

    filtered_elements =
      Enum.filter(elements, fn element ->
        Map.get(element["tags"], "name") != nil &&
          String.length(Map.get(element["tags"], "name")) >= 2 &&
          Map.get(element["tags"], "ele") != nil
      end)

    Enum.map(filtered_elements, fn element ->
      {elevation, _} = Integer.parse(Map.get(element["tags"], "ele"))

      %{
        latitude: element["lat"],
        longitude: element["lon"],
        osm_id: element["id"],
        name: Map.get(element["tags"], "name"),
        elevation: elevation,
        wikidata_id: Map.get(element["tags"], "wikidata"),
        wikipedia: Map.get(element["tags"], "wikipedia")
      }
    end)
  end
end
