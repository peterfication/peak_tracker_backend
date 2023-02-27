defmodule PeakTracker.Mountains.Registry do
  @moduledoc """
  The Ash registry for the mountains API.
  """

  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry(PeakTracker.Mountains.Peak)
  end
end
