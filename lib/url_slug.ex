defmodule UrlSlug do
  @moduledoc """
  Helper functions for working with slugs.
  """

  @doc """
  Generate a URL slug from a string.
  """
  def generate_slug(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.replace(~r/-+/, "-")
    |> String.trim("-")
  end
end
