defmodule PeakTrackerWeb.PeakLive.Show do
  use PeakTrackerWeb, :live_view

  alias PeakTracker.Mountains.Peak
  alias PeakTrackerWeb.Endpoint
  alias PeakTrackerWeb.PeakLive.Utils

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    peak = Peak.get!(slug, load: Utils.peak_load(socket.assigns.current_user))

    Endpoint.subscribe("peaks:scaled:#{peak.id}")
    Endpoint.subscribe("peaks:unscaled:#{peak.id}")

    {:noreply,
     socket
     |> assign(:page_title, "Peak #{peak.name}")
     |> assign(:peak, peak)}
  end

  @impl true
  def handle_event("scale", %{"id" => _id}, socket) do
    peak =
      socket.assigns.peak
      |> Peak.scale!(actor: socket.assigns.current_user)
      |> Map.put(:scaled_by_user, true)

    {:noreply, assign(socket, :peak, peak)}
  end

  def handle_event("unscale", %{"id" => _id}, socket) do
    peak =
      socket.assigns.peak
      |> Peak.unscale!(actor: socket.assigns.current_user)
      |> Map.put(:scaled_by_user, false)

    {:noreply, assign(socket, :peak, peak)}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "peaks:scaled:" <> _id}, socket) do
    peak = socket.assigns.peak |> Map.put(:scale_count, socket.assigns.peak.scale_count + 1)
    {:noreply, assign(socket, :peak, peak)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: "peaks:unscaled:" <> _id}, socket) do
    peak = socket.assigns.peak |> Map.put(:scale_count, socket.assigns.peak.scale_count - 1)
    {:noreply, assign(socket, :peak, peak)}
  end
end
