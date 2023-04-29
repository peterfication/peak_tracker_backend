defmodule PeakTrackerWeb.PeakLive.Index do
  use PeakTrackerWeb, :live_view

  alias PeakTracker.Mountains.Peak
  alias PeakTrackerWeb.Endpoint

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Peaks
    </.header>

    <.table id="peaks" rows={@peaks} row_click={&JS.navigate(~p"/peaks/#{&1.slug}")}>
      <:col :let={peak} label="Name"><%= peak.name %></:col>
      <:col :let={peak} label="Text">
        <%= peak.latitude %>
        <%= peak.longitude %>
        <%= if @current_user == nil do %>
          <button>
            <Heroicons.flag class="h-4 w-4" />
          </button>
        <% else %>
          <%= if peak.scaled_by_user do %>
            <button phx-click="unscale" phx-value-id={peak.id}>
              <Heroicons.flag class="h-4 w-4 fill-blue-700" />
            </button>
          <% else %>
            <button phx-click="scale" phx-value-id={peak.id}>
              <Heroicons.flag class="h-4 w-4" />
            </button>
          <% end %>
        <% end %>
        <%= peak.scale_count %>
      </:col>
      <:action :let={peak}>
        <div class="sr-only">
          <.link navigate={~p"/peaks/#{peak}"}>Show</.link>
        </div>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_peaks(socket)}
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

  @impl true
  def handle_event("unscale", %{"id" => id}, socket) do
    peak =
      socket.assigns.peaks
      |> Enum.find(&(&1.id == id))
      |> Peak.unscale!(actor: socket.assigns.current_user)
      |> Map.put(:scaled_by_user, false)

    {:noreply, assign(socket, :peaks, replace_peak(socket.assigns.peaks, peak))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: "peaks:scaled:" <> id}, socket) do
    {:noreply, assign(socket, :peaks, peak_scaled(socket.assigns.peaks, id))}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{topic: "peaks:unscaled:" <> id}, socket) do
    {:noreply, assign(socket, :peaks, peak_unscaled(socket.assigns.peaks, id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Peaks")
    |> assign(:peak, nil)
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

  defp subscribe(peak) do
    Endpoint.subscribe("peaks:scaled:#{peak.id}")
    Endpoint.subscribe("peaks:unscaled:#{peak.id}")
  end

  # Needed as soon as pagination is in place
  # defp unsubscribe(id) do
  #   Endpoint.unsubscribe("peaks:scaled:#{id}")
  #   Endpoint.unsubscribe("peaks:unscaled:#{id}")
  # end

  defp assign_peaks(socket) do
    peaks = Peak.list!(load: peak_load(socket.assigns.current_user)).results

    Enum.each(peaks, &subscribe/1)
    assign(socket, peaks: peaks)
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

  defp peak_load(current_user) when current_user == nil, do: [:scale_count]

  defp peak_load(current_user) do
    [
      :scale_count,
      scaled_by_user: %{user_id: current_user.id}
    ]
  end
end
