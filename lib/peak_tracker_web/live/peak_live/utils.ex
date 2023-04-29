defmodule PeakTrackerWeb.PeakLive.Utils do
  @doc """
  When there is no current user, load only the general aggregates and calculations.

  When there is a current user, load the general aggregates and calculations
  plus the ones related to the current user.
  """
  def peak_load(current_user) when current_user == nil, do: [:scale_count]

  def peak_load(current_user),
    do: peak_load(nil) ++ [scaled_by_user: %{user_id: current_user.id}]
end
