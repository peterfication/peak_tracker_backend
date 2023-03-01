defmodule PeakTrackerWeb.PageController do
  @moduledoc """
  Controller for static pages.
  """
  use PeakTrackerWeb, :controller

  def root(conn, _params) do
    render(conn, :root)
  end
end
