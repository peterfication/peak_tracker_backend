defmodule PeakTracker.MountainsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PeakTracker.Mountains` context.
  """

  @doc """
  Generate a peak.
  """
  def peak_fixture(attrs \\ %{}) do
    PeakTracker.Mountains.Peak
    |> Ash.Changeset.for_create(
      :create,
      attrs
      |> Enum.into(%{
        name: "some name",
        slug: "some-slug",
        osm_id: 123_456_789,
        latitude: 40.1,
        longitude: 10.2,
        elevation: 1234,
        wikidata_id: "Q12345"
      })
    )
    |> PeakTracker.Mountains.create!()
  end
end
