defmodule PeakTracker.GetSecret do
  @moduledoc """
  This module is used to get secrets from the environment or a local default.
  """
  use AshAuthentication.Secret

  @spec get_secret_from_env_or_local_default(atom, String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  defp get_secret_from_env_or_local_default(key, local_default) do
    if Mix.env() in [:dev, :test] do
      {:ok, local_default}
    else
      Application.fetch_env!(:peak_tracker, key)
    end
  end

  # OAuth2 secrets/configuration
  def secret_for(
        [:authentication, :strategies, :peak_tracker_auth, :client_id],
        PeakTracker.Accounts.User,
        _opts
      ),
      do: get_secret_from_env_or_local_default(:oauth_client_id, "local-abc-123")

  def secret_for(
        [:authentication, :strategies, :peak_tracker_auth, :client_secret],
        PeakTracker.Accounts.User,
        _opts
      ),
      do: get_secret_from_env_or_local_default(:oauth_client_secret, "local-secret-abc-123")

  def secret_for(
        [:authentication, :strategies, :peak_tracker_auth, :site],
        PeakTracker.Accounts.User,
        _opts
      ),
      do: get_secret_from_env_or_local_default(:oauth_site, "http://localhost:3000/")

  def secret_for(
        [:authentication, :strategies, :peak_tracker_auth, :authorize_url],
        PeakTracker.Accounts.User,
        _opts
      ),
      do:
        get_secret_from_env_or_local_default(
          :oauth_authorize_url,
          "http://localhost:3000/oauth/authorize"
        )

  def secret_for(
        [:authentication, :strategies, :peak_tracker_auth, :token_url],
        PeakTracker.Accounts.User,
        _opts
      ),
      do:
        get_secret_from_env_or_local_default(
          :oauth_token_url,
          "http://localhost:3000/oauth/token"
        )

  def secret_for(
        [:authentication, :strategies, :peak_tracker_auth, :user_url],
        PeakTracker.Accounts.User,
        _opts
      ),
      do:
        get_secret_from_env_or_local_default(
          :oauth_user_url,
          "http://localhost:3000/oauth/userinfo"
        )

  def secret_for(
        [:authentication, :strategies, :peak_tracker_auth, :redirect_uri],
        PeakTracker.Accounts.User,
        _opts
      ),
      do: get_secret_from_env_or_local_default(:oauth_redirect_uri, "http://localhost:4000/auth")
end
