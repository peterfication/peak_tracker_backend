defmodule PeakTracker.Schema do
  @moduledoc """
  The PeakTracker GraphQL schema definition.
  """
  use Absinthe.Schema

  @apis [PeakTracker.Mountains, PeakTracker.Accounts]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end

  def context(ctx) do
    AshGraphql.add_context(ctx, @apis)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
