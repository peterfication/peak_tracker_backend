defmodule PeakTrackerWeb.PeakLive.Index do
  use PeakTrackerWeb, :live_view

  require Ash.Query

  alias PeakTracker.Mountains.Peak
  alias PeakTrackerWeb.Endpoint
  alias PeakTrackerWeb.PeakLive.Utils
  alias PeakTrackerWeb.Utils.Pagination.Keyset

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:page_title, "Listing Peaks")
      |> assign(peaks: [])
      |> assign(query: "")
      |> assign(has_previous_page: false)
      |> assign(has_next_page: false)
    }
  end

  @impl true
  def handle_params(params, _, socket) do
    peaks_data = load_peaks(params, socket)

    Enum.each(peaks_data.peaks_page.results, fn peak ->
      Endpoint.subscribe("peaks:scaled:#{peak.id}")
      Endpoint.subscribe("peaks:unscaled:#{peak.id}")
    end)

    {
      :noreply,
      socket
      |> assign(peaks: peaks_data.peaks_page.results)
      |> assign(query: params["query"])
      |> assign(:has_next_page, peaks_data.has_next_page)
      |> assign(:has_previous_page, peaks_data.has_previous_page)
    }
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, socket |> push_patch(to: ~p"/peaks?query=#{query}")}
  end

  def handle_event("page:previous", _params, socket) do
    before_keyset = List.first(socket.assigns.peaks).__metadata__.keyset

    {:noreply,
     socket |> push_patch(to: ~p"/peaks" <> "?#{query_param(socket)}before=#{before_keyset}")}
  end

  def handle_event("page:next", _params, socket) do
    after_keyset = List.last(socket.assigns.peaks).__metadata__.keyset

    {:noreply,
     socket |> push_patch(to: ~p"/peaks" <> "?#{query_param(socket)}after=#{after_keyset}")}
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
    peaks_page =
      Peak.list!(
        query: peaks_query(params),
        load: Utils.peak_load(socket.assigns.current_user),
        page: Keyset.page_param(params)
      )

    Map.merge(
      %{peaks_page: peaks_page},
      Keyset.has_previous_or_next_page(peaks_page, params)
    )
  end

  defp peaks_query(params) do
    query_ilike_value(params["query"])
    |> case do
      nil -> nil
      ilike_value -> Ash.Query.filter(Peak, fragment("? ILIKE ?", name, ^ilike_value))
    end
  end

  defp query_ilike_value(value) when is_binary(value), do: "%#{value}%"
  defp query_ilike_value(_value), do: nil

  defp query_param(socket) when is_binary(socket.assigns.query) and socket.assigns.query != "",
    do: "query=#{socket.assigns.query}&"

  defp query_param(_socket), do: ""

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
