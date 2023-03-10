defmodule PeakTracker.Accounts.Registry do
  @moduledoc """
  The Ash registry for the accounts API.
  """
  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry PeakTracker.Accounts.User
    entry PeakTracker.Accounts.UserIdentity
  end
end
