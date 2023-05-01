defmodule PeakTrackerWeb.PeakLive.Index do
  use PeakTrackerWeb, :live_view

  alias PeakTracker.Mountains.Peak
  alias PeakTrackerWeb.Endpoint
  alias PeakTrackerWeb.PeakLive.Utils

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:page_title, "Listing Peaks")
      |> assign(peaks: [])
      |> assign(has_previous_page: false)
      |> assign(has_next_page: false)
    }
  end

  @impl true
  def handle_params(params, _, socket) do
    peaks_result = load_peaks(params, socket)

    {has_previous_page, has_next_page} = has_prev_next_page(peaks_result, params)

    {
      :noreply,
      socket
      |> assign(peaks: peaks_result.results)
      |> assign(:has_next_page, has_next_page)
      |> assign(:has_previous_page, has_previous_page)
    }
  end

  @impl true
  def handle_event("page:previous", _params, socket) do
    before_keyset = List.first(socket.assigns.peaks).__metadata__.keyset
    {:noreply, socket |> push_patch(to: ~p"/peaks?before=#{before_keyset}")}
  end

  def handle_event("page:next", _params, socket) do
    after_keyset = List.last(socket.assigns.peaks).__metadata__.keyset
    {:noreply, socket |> push_patch(to: ~p"/peaks?after=#{after_keyset}")}
  end

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

  defp load_peaks(params, socket) do
    page_after = params["after"]
    page_before = params["before"]

    page =
      cond do
        page_after != nil && page_after != "" -> [after: page_after]
        page_before != nil && page_before != "" -> [before: page_before]
        true -> []
      end

    peaks_page =
      Peak.list!(
        load: Utils.peak_load(socket.assigns.current_user),
        page: page
      )

    Enum.each(peaks_page.results, fn peak ->
      Endpoint.subscribe("peaks:scaled:#{peak.id}")
      Endpoint.subscribe("peaks:unscaled:#{peak.id}")
    end)

    peaks_page
  end

  defp has_prev_next_page(peaks_page, params) do
    page_after = if params["after"] == "", do: nil, else: params["after"]
    page_before = if params["before"] == "", do: nil, else: params["before"]

    case {page_after, page_before} do
      {nil, nil} ->
        {false, peaks_page.more?}

      {_, nil} ->
        {true, peaks_page.more?}

      {nil, _} ->
        {peaks_page.more?, not Enum.empty?(peaks_page.results)}
    end
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
