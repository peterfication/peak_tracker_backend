defmodule PeakTrackerWeb.PeakController do
  use PeakTrackerWeb, :controller

  alias PeakTracker.Mountains.Peak

  def index(conn, _params) do
    {:ok, page} = Peak.list(load: [:scale_count])

    render(conn, :index, peaks: page.results)
  end

  def show(conn, %{"slug" => slug}) do
    peak = Peak.get!(slug, load: [:scale_count])

    render(conn, :show, peak: peak)
  end
end
