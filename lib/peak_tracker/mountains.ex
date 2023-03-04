defmodule PeakTracker.Mountains do
  @moduledoc """
  PeakTracker.Mountains is responsible for managing data about mountains.
  """

  use Ash.Api,
    extensions: [
      AshGraphql.Api
    ]

  graphql do
    # TODO: Remove this once authorization is implemented
    authorize?(false)
  end

  resources do
    registry(PeakTracker.Mountains.Registry)
  end

  alias PeakTracker.Mountains.Peak

  @doc """
  Returns the list of peaks.

  ## Examples

      iex> list_peaks()
      [%Peak{}, ...]

  """
  def list_peaks do
    Peak
    |> Ash.Query.sort([:name])
    |> read!()
  end

  @doc """
  Gets a single peak by its slug.

  Raises `Ecto.NoResultsError` if the Peak does not exist.

  ## Examples

      iex> get_peak!("some-slug")
      %Peak{}

      iex> get_peak!("some-other-slug")
      ** (Ecto.NoResultsError)

  """
  def get_peak!(slug), do: PeakTracker.Repo.get_by!(Peak, slug: slug)

  @doc """
  Gets a single peak by its slug or nil.

  ## Examples

      iex> get_peak("some-slug")
      %Peak{}

      iex> get_peak("some-other-slug")
      nil
  """
  def get_peak(slug), do: PeakTracker.Repo.get_by(Peak, slug: slug)
end
