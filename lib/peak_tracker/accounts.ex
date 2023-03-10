defmodule PeakTracker.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Ash.Api

  resources do
    registry PeakTracker.Accounts.Registry
  end
end
