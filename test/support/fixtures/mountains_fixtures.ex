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
        slug: "some-slug"
      })
    )
    |> PeakTracker.Mountains.create!()
  end
end
