defmodule PeakTracker.Mountains do
  @moduledoc """
  PeakTracker.Mountains is responsible for managing data about mountains.
  """

  use Ash.Api,
    otp_app: :peak_tracker,
    extensions: [
      AshGraphql.Api
    ]

  graphql do
    # TODO: Remove this once authorization is implemented
    authorize?(true)
  end

  resources do
    registry(PeakTracker.Mountains.Registry)
  end
end
