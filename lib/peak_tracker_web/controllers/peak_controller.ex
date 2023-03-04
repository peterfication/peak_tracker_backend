defmodule PeakTrackerWeb.PeakController do
  use PeakTrackerWeb, :controller

  alias PeakTracker.Mountains

  def index(conn, _params) do
    peaks = Mountains.Peak
    |> Ash.Query.sort([:name])
    |> Mountains.read!()
    render(conn, :index, peaks: peaks)
  end

  def show(conn, %{"slug" => slug}) do
    peak = Mountains.get_peak!(slug)
    render(conn, :show, peak: peak)
  end
end
