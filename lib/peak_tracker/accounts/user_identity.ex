defmodule PeakTracker.Accounts.UserIdentity do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.UserIdentity]

  user_identity do
    api PeakTracker.Accounts
    user_resource PeakTracker.Accounts.User
  end

  postgres do
    table "user_identities"
    repo PeakTracker.Repo
  end
end
