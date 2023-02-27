defmodule PeakTracker.Mountains do
  use Ash.Api

  resources do
    registry(PeakTracker.Mountains.Registry)
  end
end
