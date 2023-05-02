defmodule PeakTrackerWeb.PeakLive.IndexTest do
  use PeakTrackerWeb.ConnCase
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias PeakTrackerWeb.PeakLive.Index, as: Subject

  defp create_peaks() do
    %{
      peaks: [
        %PeakTracker.Mountains.Peak{
          id: 1,
          name: "Peak 1",
          __metadata__: %{keyset: "keyset_1"}
        },
        %PeakTracker.Mountains.Peak{
          id: 2,
          name: "Peak 2",
          __metadata__: %{keyset: "keyset_2"}
        }
      ]
    }
  end

  describe "integration" do
    test "lists all peaks", %{conn: conn} do
      conn = get(conn, ~p"/peaks")
      assert html_response(conn, 200) =~ "Peaks"
    end

    test "it mounts with pagination disabled", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/peaks")

      assert view |> element("h1") |> render() =~ "Listing Peaks"
      assert view |> element("[phx-click='page:previous'][disabled='disabled']") |> has_element?()
      assert view |> element("[phx-click='page:next'][disabled='disabled']") |> has_element?()
    end
  end

  describe "mount/3" do
    setup do
      SocketHelper.create_socket()
    end

    test "assigns default values to the socket", %{socket: socket} do
      {:ok, socket} = Subject.mount(%{}, %{}, socket)

      assert socket.assigns.page_title == "Listing Peaks"
      assert socket.assigns.peaks == []
      assert socket.assigns.has_previous_page == false
      assert socket.assigns.has_next_page == false
    end
  end

  describe "handle_event/3 page:previous" do
    setup do
      Map.merge(
        SocketHelper.create_socket(),
        create_peaks()
      )
    end

    test "pushes a route with the proper before query param set", %{socket: socket, peaks: peaks} do
      socket = SocketHelper.set_data(socket, peaks: peaks)

      {:noreply, socket} = Subject.handle_event("page:previous", %{}, socket)

      assert socket.redirected == {:live, :patch, %{kind: :push, to: "/peaks?before=keyset_1"}}
    end
  end

  describe "handle_event/3 page:next" do
    setup do
      Map.merge(
        SocketHelper.create_socket(),
        create_peaks()
      )
    end

    test "pushes a route with the proper after query param set", %{socket: socket, peaks: peaks} do
      socket = SocketHelper.set_data(socket, peaks: peaks)

      {:noreply, socket} = Subject.handle_event("page:next", %{}, socket)

      assert socket.redirected == {:live, :patch, %{kind: :push, to: "/peaks?after=keyset_2"}}
    end
  end
end
