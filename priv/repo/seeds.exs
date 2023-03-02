# Script for populating the database.

Enum.each(
  [
    %{name: "Zugspitze", slug: "zugspitze"},
    %{name: "Mont Blanc", slug: "mont-blanc"}
  ],
  fn %{name: name, slug: slug} ->
    {status, peak} = PeakTracker.Mountains.get(PeakTracker.Mountains.Peak, slug: slug)

    if status == :ok do
      peak
      |> Ash.Changeset.for_update(:update, %{name: name})
      |> PeakTracker.Mountains.update!()
    else
      PeakTracker.Mountains.Peak
      |> Ash.Changeset.for_create(:create, %{name: name, slug: slug})
      |> PeakTracker.Mountains.create!()
    end
  end
)
