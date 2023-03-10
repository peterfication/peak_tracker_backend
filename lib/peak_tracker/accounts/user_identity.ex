defmodule PeakTracker.Accounts.UserIdentity do
  @moduledoc """
  This is the identity resource for the user resource.

  An identity comes from an OAuth2 provider and is used to authenticate a user.
  """
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
