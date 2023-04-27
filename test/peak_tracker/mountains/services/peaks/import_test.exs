defmodule PeakTracker.Mountains.Services.Peaks.ImportTest do
  use ExUnit.Case
  import Mock

  alias PeakTracker.Mountains.Peak
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

  test "execute/2 saves new peaks" do
    with_mocks([
      {
        FetchFromOverpass,
        [],
        execute: fn _bounding_box ->
          {:ok,
           [
             %{
               osm_id: 1,
               name: "Peak 1",
               latitude: 1.5,
               longitude: 1.5,
               elevation: 1000,
               wikidata_id: "Q1",
               wikipedia: "en:Peak 1"
             },
             %{
               osm_id: 2,
               name: "Peak 2",
               latitude: 1.6,
               longitude: 1.6,
               elevation: 2000,
               wikidata_id: "Q2",
               wikipedia: "en:Peak 2"
             }
           ]}
        end
      },
      {
        Peak,
        [],
        get_by_osm_id: fn osm_id ->
          if osm_id == 1 do
            {:error, :not_found}
          else
            {:ok, %Peak{id: 2}}
          end
        end,
        create!: fn _peak_data ->
          %Peak{}
        end,
        update!: fn _peak, _peak_data ->
          %Peak{}
        end
      }
    ]) do
      Import.execute({
        %Location{latitude: 1, longitude: 1},
        %Location{latitude: 1, longitude: 1}
      })

      assert_called(
        Peak.create!(%{
          osm_id: 1,
          slug: "peak-1-1",
          name: "Peak 1",
          latitude: 1.5,
          longitude: 1.5,
          elevation: 1000,
          wikidata_id: "Q1",
          wikipedia: "en:Peak 1"
        })
      )

      assert_called(
        Peak.update!(
          %Peak{id: 2},
          %{
            name: "Peak 2",
            latitude: 1.6,
            longitude: 1.6,
            elevation: 2000,
            wikidata_id: "Q2",
            wikipedia: "en:Peak 2"
          }
        )
      )
    end
  end
end
