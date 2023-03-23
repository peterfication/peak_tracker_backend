# Script for populating the database.

for %{name: name, slug: slug} <- [
      %{name: "Zugspitze", slug: "zugspitze"},
      %{name: "Mont Blanc", slug: "mont-blanc"},
      %{name: "Mount Everest", slug: "mount-everest"},
    ] do
  # Create or update the peak
  case PeakTracker.Mountains.Peak.get(slug) do
    {:ok, peak} -> PeakTracker.Mountains.Peak.update!(peak, %{name: name})
    {:error, _} ->PeakTracker.Mountains.Peak.create!(%{name: name, slug: slug})
  end
end
