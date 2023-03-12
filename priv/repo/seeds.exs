# Script for populating the database.

for %{name: name, slug: slug} <- [
      %{name: "Zugspitze", slug: "zugspitze"},
      %{name: "Mont Blanc", slug: "mont-blanc"}
    ] do
  # Create or update the peak
  case PeakTracker.Mountains.get(PeakTracker.Mountains.Peak, slug: slug) do
    {:ok, peak} ->
      peak
      |> Ash.Changeset.for_update(:update, %{name: name})
      |> PeakTracker.Mountains.update!()

    {:error, _} ->
      PeakTracker.Mountains.Peak
      |> Ash.Changeset.for_create(:create, %{name: name, slug: slug})
      |> PeakTracker.Mountains.create!()
  end
end
