defmodule PeakTracker.Mountains.Services.Peaks.ImportTest do
  use ExUnit.Case
  import Mock

  alias PeakTracker.Mountains.Services.Peaks.FetchFromOverpass
  alias PeakTracker.Mountains.Services.Peaks.Import

  test "execute/2 calls FetchFromOverpass with all expanded locations" do
    with_mock FetchFromOverpass, execute: fn _bounding_box -> {:ok, []} end do
      Import.execute({
        %Location{latitude: 1, longitude: 1},
        %Location{latitude: 3, longitude: 3}
      })

      assert_called(
        FetchFromOverpass.execute({
          %Location{latitude: 1, longitude: 1},
          %Location{latitude: 2, longitude: 2}
        })
      )

      assert_called(
        FetchFromOverpass.execute({
          %Location{latitude: 1, longitude: 2},
          %Location{latitude: 2, longitude: 3}
        })
      )

      assert_called(
        FetchFromOverpass.execute({
          %Location{latitude: 2, longitude: 1},
          %Location{latitude: 3, longitude: 2}
        })
      )

      assert_called(
        FetchFromOverpass.execute({
          %Location{latitude: 2, longitude: 2},
          %Location{latitude: 3, longitude: 3}
        })
      )
    end
  end
end
