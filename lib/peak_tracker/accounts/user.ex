defmodule PeakTracker.Accounts.User do
  @moduledoc """
  This is the user resource for the application.
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key(:id)
    attribute(:email, :ci_string, allow_nil?: false)
  end

  authentication do
    api PeakTracker.Accounts

    strategies do
      oauth2 :peak_tracker_auth do
        client_id PeakTracker.GetSecret
        client_secret PeakTracker.GetSecret
        authorization_params scope: "openid email"
        site PeakTracker.GetSecret
        authorize_url PeakTracker.GetSecret
        token_url PeakTracker.GetSecret
        user_url PeakTracker.GetSecret
        redirect_uri PeakTracker.GetSecret

        sign_in_action_name :sign_in_with_peak_tracker_auth
        register_action_name :register_with_peak_tracker_auth
        identity_resource PeakTracker.Accounts.UserIdentity
      end
    end
  end

  actions do
    defaults([:read])

    read :sign_in_with_peak_tracker_auth do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      prepare AshAuthentication.Strategy.OAuth2.SignInPreparation

      filter expr(email == get_path(^arg(:user_info), [:email]))
    end

    create :register_with_peak_tracker_auth do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :email

      change AshAuthentication.GenerateTokenChange
      change AshAuthentication.Strategy.OAuth2.IdentityChange

      change fn changeset, _ctx ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        changeset
        |> Ash.Changeset.change_attribute(:email, user_info["email"])
      end
    end
  end

  postgres do
    table("users")
    repo(PeakTracker.Repo)
  end

  identities do
    identity(:email, [:email])
  end
end
