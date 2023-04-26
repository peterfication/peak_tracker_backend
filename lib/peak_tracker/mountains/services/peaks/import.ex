defmodule PeakTracker.Mountains.Services.Peaks.Import do
  @moduledoc """
  Import peaks from Overpass API into the database.
  """

  alias PeakTracker.Mountains.Peak
  alias PeakTracker.Mountains.Services.Peaks.FetchFromOverpass

  @type peak_data :: FetchFromOverpass.peak()
  @type location :: FetchFromOverpass.location()

  @doc """
  Import peaks from Overpass API into the database. The import is split
  up in to bounding boxes of size 1 degree in each direction.

  ## Examples

      iex> location_a = %{latitude: 46, longitude: 9}
      iex> location_b = %{latitude: 48, longitude: 11}
      iex> PeakTracker.Mountains.Services.Peaks.Import.execute(location_a, location_b)
  """
  @spec expand_locations(location, location) :: nil
  def execute(location_a, location_b) do
    # TODO: Add tests for this method

    # TODO: Use Task.async_stream here to add concurrency to the import.
    Enum.each(expand_locations(location_a, location_b), fn location ->
      fetch_and_save(location)
    end)
  end

  @doc """
  Takes a bounding box of two locations that have full degree geo coordinates
  and returns a map of bounding boxes in the size of one degree in each direction.
  """
  @spec expand_locations(location, location) :: [location]
  def expand_locations(location_a, location_b) do
    # TODO: Create a location struct
    latitude_a = trunc(location_a.latitude)
    longitude_a = trunc(location_a.longitude)
    latitude_b = trunc(location_b.latitude)
    longitude_b = trunc(location_b.longitude)

    # TODO: convert into a guard
    if latitude_a == latitude_b && longitude_a == longitude_b do
      []
    else
      for latitude <- latitude_a..latitude_b,
          longitude <- longitude_a..longitude_b,
          do: %{latitude: latitude, longitude: longitude}
    end
  end

  @spec fetch_and_save(location) :: [Peak.t()] | nil
  defp fetch_and_save(location_a) do
    location_b = %{latitude: location_a.latitude + 1, longitude: location_a.longitude + 1}
    result = FetchFromOverpass.execute(location_a, location_b)

    # TODO: Return tuples here and in the other methods
    case result do
      {:ok, peaks} ->
        save_peaks(peaks)

      {:error, message} ->
        IO.puts(message)
    end
  end

  @spec save_peaks([peak_data]) :: [Peak.t()]
  defp save_peaks(peaks) do
    Enum.map(peaks, fn peak -> save_peak(peak) end)
  end

  @spec save_peak(peak_data) :: Peak.t()
  defp save_peak(peak_data) do
    case Peak.get_by_osm_id(peak_data[:osm_id]) do
      {:ok, peak} ->
        update_peak(peak, peak_data)

      {:error, _} ->
        create_peak(peak_data)
    end
  end

  @spec update_peak(Peak.t(), peak_data) :: Peak.t()
  defp update_peak(peak, peak_data) do
    Peak.update!(
      peak,
      %{
        name: peak_data[:name],
        latitude: peak_data[:latitude],
        longitude: peak_data[:longitude],
        elevation: peak_data[:elevation],
        wikidata_id: peak_data[:wikidata_id],
        wikipedia: peak_data[:wikipedia]
      }
    )
  end

  @spec create_peak(peak_data) :: Peak.t()
  defp create_peak(peak_data) do
    Peak.create!(%{
      osm_id: peak_data[:osm_id],
      slug: UrlSlug.generate_slug("#{peak_data[:name]}-#{peak_data[:osm_id]}"),
      name: peak_data[:name],
      latitude: peak_data[:latitude],
      longitude: peak_data[:longitude],
      elevation: peak_data[:elevation],
      wikidata_id: peak_data[:wikidata_id],
      wikipedia: peak_data[:wikipedia]
    })
  end
end
