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
  @type bounding_box :: {t, t}

  @doc """
  Takes a bounding box of two locations that will be truncated to have full
  degree geo coordinates and returns a map of bounding boxes in the size of
  one degree in each direction.

  If the two locations have the same whole degree, the list will be an element
  with just one location which is the truncated location.
  """
  @spec expand_locations(bounding_box) :: [bounding_box]
  def expand_locations({location_a, location_b}) do
    truncated_location_a = truncate_location(location_a)
    truncated_location_b = truncate_location(location_b)
    # TODO: Sort the two locations so that the below algorithm works as expected

    if equals(truncated_location_a, truncated_location_b) do
      # If the locations are the same, we return one bounding box.
      [
        {
          truncated_location_a,
          add_one_degree(truncated_location_a)
        }
      ]
    else
      # The -1 on truncated location b is necessary because later on the boxes generated
      # from the locations will be from the returned location +1 in each direction.
      for latitude <-
            truncated_location_a.latitude..max(
              truncated_location_a.latitude,
              truncated_location_b.latitude - 1
            ),
          longitude <-
            truncated_location_a.longitude..max(
              truncated_location_a.longitude,
              truncated_location_b.longitude - 1
            ) do
        location = %Location{latitude: latitude, longitude: longitude}

        {location, add_one_degree(location)}
      end
    end
  end

  @doc """
  Checks if two locations are equal by comparing their latitude and longitude.
  """
  @spec equals(t, t) :: Boolean
  def equals(location_a, location_b),
    do:
      location_a.latitude == location_b.latitude &&
        location_a.longitude == location_b.longitude

  @doc """
  Truncates the latitude and longitude of a location to a whole degree.
  """
  @spec truncate_location(t) :: t
  def truncate_location(location),
    do: %Location{latitude: trunc(location.latitude), longitude: trunc(location.longitude)}

  @doc """
  Adds one degree to the latitude and longitude of a location.
  """
  @spec add_one_degree(t) :: t
  def add_one_degree(location),
    do: %Location{latitude: location.latitude + 1, longitude: location.longitude + 1}
end
