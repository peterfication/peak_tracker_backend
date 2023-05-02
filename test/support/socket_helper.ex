defmodule SocketHelper do
  use PeakTrackerWeb, :live_view

  def render(assigns) do
    ~H"""
    Empty
    """
  end

  def set_data(socket, data) do
    socket |> assign(data)
  end

  def create_socket() do
    %{socket: %Phoenix.LiveView.Socket{}}
  end
end
