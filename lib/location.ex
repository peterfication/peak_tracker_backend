defmodule Location do
  @moduledoc """
  A location represents a latitude and longitude.
  """

  use TypeCheck

  @enforce_keys [:latitude, :longitude]
  defstruct [:latitude, :longitude]

  @type! t :: %__MODULE__{
           latitude: coordinate(),
           latitude: coordinate()
         }
  @type! coordinate :: float() | integer()
  @type! bounding_box :: {t(), t()}

  defguard is_location(value)
           when is_map(value) and
                  is_number(value.latitude) and
                  is_number(value.longitude)

  defguard is_bounding_box(value)
           when is_tuple(value) and
                  tuple_size(value) == 2 and
                  is_location(value |> elem(0)) and
                  is_location(value |> elem(1))

  @doc """
  Takes a bounding box of two locations that will be truncated to have full
  degree geo coordinates and returns a map of bounding boxes in the size of
  one degree in each direction.

  If the two locations have the same whole degree, the list will be an element
  with just one location which is the truncated location.
  """
  @spec! expand_locations(bounding_box()) :: [bounding_box()]
  def expand_locations(bounding_box) when not is_bounding_box(bounding_box), do: []

  def expand_locations(bounding_box) do
    %{
      min_latitude: min_latitude,
      max_latitude: max_latitude,
      min_longitude: min_longitude,
      max_longitude: max_longitude
    } = min_max_longitude_and_latitude(bounding_box)

    for latitude <- min_latitude..max(min_latitude, max_latitude - 1),
        longitude <- min_longitude..max(min_longitude, max_longitude - 1) do
      location = %Location{latitude: latitude, longitude: longitude}

      {location, add_one_degree(location) |> elem(1)}
    end
  end

  ##
  # Get the minimum and maximum latitude and longitude of a bounding box.
  @spec! min_max_longitude_and_latitude(bounding_box()) :: %{
           max_latitude: coordinate(),
           max_longitude: coordinate(),
           min_latitude: coordinate(),
           min_longitude: coordinate()
         }
  defp min_max_longitude_and_latitude({location_a, location_b}) do
    truncated_location_a = truncate_location(location_a) |> elem(1)
    truncated_location_b = truncate_location(location_b) |> elem(1)

    %{
      max_latitude: max(truncated_location_a.latitude, truncated_location_b.latitude),
      max_longitude: max(truncated_location_a.longitude, truncated_location_b.longitude),
      min_latitude: min(truncated_location_a.latitude, truncated_location_b.latitude),
      min_longitude: min(truncated_location_a.longitude, truncated_location_b.longitude)
    }
  end

  @doc """
  Checks if two locations are equal by comparing their latitude and longitude.
  """
  @spec! equals(t(), t()) :: boolean()
  def equals(location_a, location_b)
      when not is_location(location_a) or not is_location(location_b),
      do: false

  def equals(location_a, location_b),
    do:
      location_a.latitude == location_b.latitude &&
        location_a.longitude == location_b.longitude

  @doc """
  Truncates the latitude and longitude of a location to a whole degree.
  """
  @spec! truncate_location(t()) :: {:ok, t()} | {:error, String.t()}
  def truncate_location(location) when not is_location(location),
    do: {:error, "Expected a location, got #{inspect(location)}"}

  def truncate_location(location),
    do: {:ok, %Location{latitude: trunc(location.latitude), longitude: trunc(location.longitude)}}

  @doc """
  Adds one degree to the latitude and longitude of a location.
  """
  @spec! add_one_degree(t()) :: {:ok, t()} | {:error, String.t()}
  def add_one_degree(location) when not is_location(location),
    do: {:error, "Expected a location, got #{inspect(location)}"}

  def add_one_degree(location),
    do: {:ok, %Location{latitude: location.latitude + 1, longitude: location.longitude + 1}}
end
