defmodule PeakTracker.Mountains.Peak do
  @moduledoc """
  A Peak represents a mountain peak.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  postgres do
    table("peaks")
    repo(PeakTracker.Repo)
  end

  graphql do
    type(:peak)

    queries do
      list(:peaks, :read_paginated, relay?: true)
      get(:peak, :read)
    end
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :read_paginated do
      pagination(
        required?: true,
        offset?: true,
        countable: true,
        keyset?: true,
        default_limit: 20
      )
    end
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
    end

    timestamps()
  end
end
