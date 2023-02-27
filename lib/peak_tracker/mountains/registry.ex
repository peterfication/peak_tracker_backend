defmodule PeakTracker.Mountains.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry(PeakTracker.Mountains.Peak)
  end
end
