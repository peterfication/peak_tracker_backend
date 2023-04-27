defmodule Location do
  @moduledoc """
  A location represents a latitude and longitude.
  """

  @enforce_keys [:latitude, :longitude]
  defstruct [:latitude, :longitude]

  @type t :: %__MODULE__{
          latitude: coordinate,
          latitude: coordinate
        }
  @type coordinate :: float()

  @doc """
  Takes a bounding box of two locations that have full degree geo coordinates
  and returns a map of bounding boxes in the size of one degree in each direction.
  """
  @spec expand_locations(t, t) :: [t]
  def expand_locations(location_a, location_b) do
    latitude_a = trunc(location_a.latitude)
    longitude_a = trunc(location_a.longitude)
    latitude_b = trunc(location_b.latitude)
    longitude_b = trunc(location_b.longitude)

    # TODO: convert into a guard
    if latitude_a == latitude_b && longitude_a == longitude_b do
      []
    else
      for latitude <- latitude_a..latitude_b,
          longitude <- longitude_a..longitude_b,
          do: %Location{latitude: latitude, longitude: longitude}
    end
  end
end
