defmodule PeakTracker.Mountains do
  @moduledoc """
  PeakTracker.Mountains is responsible for managing data about mountains.
  """

  use Ash.Api

  resources do
    registry(PeakTracker.Mountains.Registry)
  end
end
