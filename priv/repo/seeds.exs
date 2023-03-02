# Script for populating the database.

peaks_data = [
  %{name: "Zugspitze", slug: "zugspitze"},
  %{name: "Mont Blanc", slug: "mont-blanc"},
]

# loop through the peaks and create or update them
for peak_data <- peaks_data do
  # Get a peak
  {status, peak} = PeakTracker.Mountains.get(PeakTracker.Mountains.Peak, slug: peak_data.slug)

  if status == :ok do
    # Update the peak if it exists
    peak
    |> Ash.Changeset.for_update(:update, %{name: peak_data.name})
    |> PeakTracker.Mountains.update!()
  else
    # Create the peak if it doesn't exist
    PeakTracker.Mountains.Peak
    |> Ash.Changeset.for_create(:create, %{name: peak_data.name, slug: peak_data.slug})
    |> PeakTracker.Mountains.create!()
  end
end
