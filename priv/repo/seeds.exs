# Script for populating the database.

# Get a peak
{status, peak} = PeakTracker.Mountains.get(PeakTracker.Mountains.Peak, slug: "zugspitze")

if status == :ok do
  # Update the peak
  peak
  |> Ash.Changeset.for_update(:update, %{name: "Zugspitze"})
  |> PeakTracker.Mountains.update!()
else
  # Create the peak if it doesn't exist
  PeakTracker.Mountains.Peak
  |> Ash.Changeset.for_create(:create, %{name: "Zugspitze", slug: "zugspitze"})
  |> PeakTracker.Mountains.create!()
end
