defmodule PeakTrackerWeb.Utils.Pagination.Keyset do
  @moduledoc """
  Helper functions for Ash pagination with keyset when dealing with
  params from a client.
  """

  use TypeCheck

  @doc """
  Generate the page params that are passed to the Ash read_paginated function
  depending on the params (after, before) received from a client.

  ## Examples

      iex> PeakTrackerWeb.Utils.Pagination.Keyset.page_param(%{"after" => "foo"})
      [after: "foo"]

      iex> PeakTrackerWeb.Utils.Pagination.Keyset.page_param(%{"before" => "bar"})
      [before: "bar"]

      iex> PeakTrackerWeb.Utils.Pagination.Keyset.page_param(%{})
      []
  """
  @spec! page_param(map()) :: [] | [after: String.t()] | [before: String.t()]
  def page_param(%{"after" => page_after}) when page_after != nil and page_after != "",
    do: [after: page_after]

  def page_param(%{"before" => page_before}) when page_before != nil and page_before != "",
    do: [before: page_before]

  def page_param(_), do: []

  @doc """
  Calculate has previous and has next page based on the cursor based
  pagination params "after" and "before".

  ## Examples

      iex> PeakTrackerWeb.Utils.Pagination.Keyset.has_previous_or_next_page(page, %{"after" => "foo"})
      %{has_previous_page: true, has_next_page: true}
  """
  @spec! has_previous_or_next_page(map(), map()) ::
           %{has_previous_page: boolean(), has_next_page: boolean()}
  def has_previous_or_next_page(page, params) do
    page_after = if params["after"] == "", do: nil, else: params["after"]
    page_before = if params["before"] == "", do: nil, else: params["before"]

    more = if Map.has_key?(page, :more?), do: page.more?, else: false
    results = if Map.has_key?(page, :results), do: page.results, else: []

    {has_previous_page, has_next_page} =
      case {page_after, page_before} do
        {nil, nil} ->
          {false, more}

        {_, nil} ->
          {true, more}

        {nil, _} ->
          # See https://github.com/ash-project/ash_graphql/pull/36#issuecomment-1243892511
          {more, not Enum.empty?(results)}
      end

    %{has_previous_page: has_previous_page, has_next_page: has_next_page}
  end
end
