defmodule PeakTracker.Accounts.Registry do
  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry PeakTracker.Accounts.User
    entry PeakTracker.Accounts.UserIdentity
  end
end
