# Script for populating the database.

for %{
      name: name,
      slug: slug,
      osm_id: osm_id,
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      wikidata_id: wikidata_id,
      wikipedia: wikipedia
    } <- [
      %{
        name: "Zugspitze",
        slug: "zugspitze",
        osm_id: 27_384_190,
        latitude: 47.421215,
        longitude: 10.986297,
        elevation: 2962,
        wikidata_id: "Q3375",
        wikipedia: "de:Zugspitze"
      },
      %{
        name: "Brocken",
        slug: "brocken",
        osm_id: 26_862_634,
        latitude: 51.7991251,
        longitude: 10.6156365,
        elevation: 1141,
        wikidata_id: "Q155721",
        wikipedia: "de:Brocken"
      }
    ] do
  # Create or update the peak
  case PeakTracker.Mountains.Peak.get(slug) do
    {:ok, peak} ->
      PeakTracker.Mountains.Peak.update!(
        peak,
        %{
          name: name,
          osm_id: osm_id,
          latitude: latitude,
          longitude: longitude,
          elevation: elevation,
          wikidata_id: wikidata_id,
          wikipedia: wikipedia
        }
      )

    {:error, _} ->
      PeakTracker.Mountains.Peak.create!(%{
        name: name,
        slug: slug,
        osm_id: osm_id,
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        wikidata_id: wikidata_id,
        wikipedia: wikipedia
      })
  end
end
