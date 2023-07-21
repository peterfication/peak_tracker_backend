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

  def context(ctx),
    do:
      ctx
      |> add_default_actor_to_context()

  # If there is no current user / actor, set an empty actor so that
  # the currentUser field will return null instead of an actor error.
  # TODO: Check if there is a better solution to this.
  defp add_default_actor_to_context(ctx) when ctx.actor == nil,
    do: Map.put(ctx, :actor, %PeakTracker.Accounts.User{})

  defp add_default_actor_to_context(ctx), do: ctx

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
