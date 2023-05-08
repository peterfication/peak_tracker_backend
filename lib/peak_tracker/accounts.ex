defmodule PeakTracker.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Ash.Api,
    otp_app: :peak_tracker,
    extensions: [
      AshGraphql.Api
    ]

  graphql do
    authorize?(true)
  end

  resources do
    registry(PeakTracker.Accounts.Registry)
  end
end
