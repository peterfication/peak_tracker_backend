defmodule PeakTracker.Mountains.Services.Peaks.ImportWorldTest do
  use ExUnit.Case
  import Mock

  alias PeakTracker.Mountains.Services.Peaks.Import
  alias PeakTracker.Mountains.Services.Peaks.ImportWorld

  test "import_world/0 calls Import and returns its result" do
    with_mock Import, execute: fn _location_a, _location_b -> :ok end do
      assert ImportWorld.execute() == :ok
    end
  end
end
