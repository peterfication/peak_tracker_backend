defmodule PeakTracker.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  # AshAuthentication.Strategy.OAuth2
  # AshAuthentication.Strategy.OIDC

  attributes do
    uuid_primary_key(:id)
    # attribute(:sub, :ci_string, allow_nil?: false)
    attribute(:email, :ci_string, allow_nil?: false)
  end

  authentication do
    api PeakTracker.Accounts

    strategies do
      # oidc :oidc do
      #   identity_field :email
      # end

      oauth2 :peak_tracker_auth do
        # System.fetch_env!("CLIENT_ID")
        # Application.fetch_env(:my_app, resource, :oauth2_client_secret)
        client_id "V2A4VoVXZjdZ16E4RIcEdxRhexJE5OyICowHbXap8Ag"
        redirect_uri "http://localhost:4000/auth"
        client_secret "J0vG4ajI0Ac1tBG_439BxiwPxd5J8PYEJb5fCVEYonA"
        site "http://localhost:3000/"
        authorize_url "http://localhost:3000/oauth/authorize"
        token_url "http://localhost:3000/oauth/token"
        user_url "http://localhost:3000/oauth/userinfo"

        # icon(:github)
        authorization_params scope: "openid email"
        # response_type: "code",
        # scope: "openid email"
        # discovery_document_uri: "http://localhost:3000/.well-known/openid-configuration",

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
