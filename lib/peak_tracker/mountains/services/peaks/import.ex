defmodule PeakTracker.Mountains.Services.Peaks.Import do
  @moduledoc """
  Import peaks from Overpass API into the database.
  """

  alias PeakTracker.Mountains.Peak
  alias PeakTracker.Mountains.Services.Peaks.FetchFromOverpass

  @type peak_data :: FetchFromOverpass.peak_data()
  @type bounding_box :: Location.bounding_box()
  @type peak :: Peak.t()

  @doc """
  Import peaks from Overpass API into the database. The import is split
  up in to bounding boxes of size 1 degree in each direction.

  ## Examples

      iex> location_a = %{latitude: 46, longitude: 9}
      iex> location_b = %{latitude: 48, longitude: 11}
      iex> PeakTracker.Mountains.Services.Peaks.Import.execute(location_a, location_b)
  """
  @spec execute(bounding_box) :: :ok
  def execute(bounding_box) do
    # TODO: Use Task.async_stream here to add concurrency to the import.
    Enum.each(Location.expand_locations(bounding_box), fn bounding_box ->
      fetch_and_save(bounding_box)
    end)
  end

  @spec fetch_and_save(bounding_box) :: :ok
  defp fetch_and_save(bounding_box) do
    case FetchFromOverpass.execute(bounding_box) do
      {:ok, peak_data_list} ->
        save_peaks(peak_data_list)

      {:error, message} ->
        IO.puts(message)
    end
  end

  @spec save_peaks([peak_data]) :: :ok
  defp save_peaks(peak_data_list) do
    Enum.each(peak_data_list, fn peak_data -> save_peak(peak_data) end)
  end

  @spec save_peak(peak_data) :: {:ok, peak} | {:error, String.t()}
  defp save_peak(peak_data) do
    case Peak.get_by_osm_id(peak_data[:osm_id]) do
      {:ok, peak} ->
        update_peak(peak, peak_data)

      {:error, _} ->
        create_peak(peak_data)
    end
  end

  @spec update_peak(peak, peak_data) :: {:ok, peak} | {:error, String.t()}
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

  @spec create_peak(peak_data) :: {:ok, peak} | {:error, String.t()}
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
