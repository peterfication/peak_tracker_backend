defmodule PeakTrackerWeb.PeakController do
  use PeakTrackerWeb, :controller

  alias PeakTracker.Mountains.Peak

  def index(conn, _params) do
    {:ok, page} = Peak.list()

    render(conn, :index, peaks: page.results)
  end

  def show(conn, %{"slug" => slug}) do
    peak = Peak.get!(slug)

    render(conn, :show, peak: peak)
  end
end
