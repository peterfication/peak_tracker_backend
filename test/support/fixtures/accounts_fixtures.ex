defmodule PeakTracker.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PeakTracker.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    PeakTracker.Accounts.User
    |> Ash.Changeset.for_create(
      :create,
      attrs
      |> Enum.into(%{
        email: "mail@example.com"
      })
    )
    |> PeakTracker.Accounts.create!()
  end
end
