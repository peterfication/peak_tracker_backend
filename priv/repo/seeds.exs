# Script for populating the database.

PeakTracker.Mountains.Peak
|> Ash.Changeset.for_create(:create, %{name: "Zugspitze"})
|> PeakTracker.Mountains.create!()
