defmodule PeakTrackerWeb.PeakLive.Index do
  use PeakTrackerWeb, :live_view

  alias PeakTracker.Mountains.Peak
  alias PeakTrackerWeb.Endpoint
  alias PeakTrackerWeb.PeakLive.Utils

  @impl true
  def mount(_params, _session, socket) do
    peaks = Peak.list!(load: Utils.peak_load(socket.assigns.current_user)).results

    Enum.each(peaks, fn peak ->
      Endpoint.subscribe("peaks:scaled:#{peak.id}")
      Endpoint.subscribe("peaks:unscaled:#{peak.id}")
    end)

    {:ok, socket |> assign(:page_title, "Listing Peaks") |> assign(peaks: peaks)}
  end

  @impl true
  def handle_event("scale", %{"id" => id}, socket) do
    peak =
      socket.assigns.peaks
      |> Enum.find(&(&1.id == id))
      |> Peak.scale!(actor: socket.assigns.current_user)
      |> Map.put(:scaled_by_user, true)

    {:noreply, assign(socket, :peaks, replace_peak(socket.assigns.peaks, peak))}
  end

  def handle_event("unscale", %{"id" => id}, socket) do
    peak =
      socket.assigns.peaks
      |> Enum.find(&(&1.id == id))
      |> Peak.unscale!(actor: socket.assigns.current_user)
      |> Map.put(:scaled_by_user, false)

    {:noreply, assign(socket, :peaks, replace_peak(socket.assigns.peaks, peak))}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "peaks:scaled:" <> id}, socket) do
    {:noreply, assign(socket, :peaks, peak_scaled(socket.assigns.peaks, id))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: "peaks:unscaled:" <> id}, socket) do
    {:noreply, assign(socket, :peaks, peak_unscaled(socket.assigns.peaks, id))}
  end

  defp replace_peak(peaks, peak) do
    Enum.map(peaks, fn current_peak ->
      if current_peak.id == peak.id do
        peak
      else
        current_peak
      end
    end)
  end

  defp peak_scaled(peaks, id) do
    update_peak(peaks, id, &%{&1 | scale_count: &1.scale_count + 1})
  end

  defp peak_unscaled(peaks, id) do
    update_peak(peaks, id, &%{&1 | scale_count: &1.scale_count - 1})
  end

  defp update_peak(peaks, id, func) do
    Enum.map(peaks, fn peak ->
      if peak.id == id do
        func.(peak)
      else
        peak
      end
    end)
  end
end
