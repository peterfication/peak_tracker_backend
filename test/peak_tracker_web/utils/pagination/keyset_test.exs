defmodule PeakTrackerWeb.Utils.Pagination.KeysetTest do
  use ExUnit.Case, async: true
  use TypeCheck.ExUnit

  alias PeakTrackerWeb.Utils.Pagination.Keyset, as: Subject

  spectest(Subject)

  describe "page_param/1" do
    test "returns empty list when neither after nor before are present" do
      assert Subject.page_param(%{}) == []
    end

    test "returns after tuple when after is present and not empty" do
      assert Subject.page_param(%{"after" => "foo"}) == [after: "foo"]
    end

    test "returns before tuple when before is present and not empty" do
      assert Subject.page_param(%{"before" => "bar"}) == [before: "bar"]
    end

    test "ignores empty after value" do
      assert Subject.page_param(%{"after" => ""}) == []
    end

    test "ignores nil after value" do
      assert Subject.page_param(%{"after" => nil}) == []
    end

    test "ignores empty before value" do
      assert Subject.page_param(%{"before" => ""}) == []
    end

    test "ignores nil before value" do
      assert Subject.page_param(%{"before" => nil}) == []
    end
  end

  describe "has_previous_or_next_page/2" do
    test "when after and before are nil and page.more? is true returns false,true" do
      page = %{results: [], more?: true}
      params = %{"after" => nil, "before" => nil}
      expected_result = %{has_previous_page: false, has_next_page: true}

      assert Subject.has_previous_or_next_page(page, params) == expected_result
    end

    test "when after and before are nil and page.more? is false returns false,false" do
      page = %{results: [], more?: false}
      params = %{"after" => nil, "before" => nil}
      expected_result = %{has_previous_page: false, has_next_page: false}

      assert Subject.has_previous_or_next_page(page, params) == expected_result
    end

    test "when after is present and before is nil and page.more? is true returns true,true" do
      page = %{results: [], more?: true}
      params = %{"after" => "something", "before" => nil}
      expected_result = %{has_previous_page: true, has_next_page: true}

      assert Subject.has_previous_or_next_page(page, params) == expected_result
    end

    test "when after is present and before is nil and page.more? is false returns true,false" do
      page = %{results: [], more?: false}
      params = %{"after" => "something", "before" => nil}
      expected_result = %{has_previous_page: true, has_next_page: false}

      assert Subject.has_previous_or_next_page(page, params) == expected_result
    end

    test "when after is nil and before is present and page.more? is false and results is empty false,false" do
      page = %{results: [], more?: false}
      params = %{"after" => nil, "before" => "something"}
      expected_result = %{has_previous_page: false, has_next_page: false}

      assert Subject.has_previous_or_next_page(page, params) == expected_result
    end

    test "when after is nil and before is present and page.more? is true and results is not empty true,true" do
      page = %{results: [1], more?: true}
      params = %{"after" => nil, "before" => "something"}
      expected_result = %{has_previous_page: true, has_next_page: true}

      assert Subject.has_previous_or_next_page(page, params) == expected_result
    end
  end
end
