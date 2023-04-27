defmodule UrlSlugTest do
  use ExUnit.Case

  test "slug generation with lowercase string" do
    assert UrlSlug.generate_slug("elixir is awesome") == "elixir-is-awesome"
  end

  test "slug generation with uppercase string" do
    assert UrlSlug.generate_slug("ELIXIR IS AWESOME") == "elixir-is-awesome"
  end

  test "slug generation with mixed case string" do
    assert UrlSlug.generate_slug("Elixir is Awesome!") == "elixir-is-awesome"
  end

  test "slug generation with special characters" do
    assert UrlSlug.generate_slug("Elixir: 100% Awesome!") == "elixir-100-awesome"
  end

  test "slug generation with extra spaces" do
    assert UrlSlug.generate_slug(" Elixir   is  Awesome! ") == "elixir-is-awesome"
  end
end
