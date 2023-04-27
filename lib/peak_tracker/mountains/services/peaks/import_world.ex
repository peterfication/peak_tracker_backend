defmodule PeakTracker.Mountains.Services.Peaks.ImportWorld do
  @moduledoc """
  Import the peaks of the whole world by executing the import with
  (-90, -180) and (90, 180).

  NOTE: This will take a long time to execute and will call the Overpass API
  many times.
  """

  alias PeakTracker.Mountains.Services.Peaks.Import

  @doc """
  See module doc.
  """
  def execute do
    Import.execute({
      %Location{latitude: -90.0, longitude: -180.0},
      %Location{latitude: 90.0, longitude: 180.0}
    })
  end
end
