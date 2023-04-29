defmodule PeakTrackerWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in live views.
  """

  import Phoenix.Component

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: "/auth/user/peak_tracker_auth")}
    end
  end
end
