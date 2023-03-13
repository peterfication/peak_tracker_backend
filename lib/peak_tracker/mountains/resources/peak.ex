defmodule PeakTracker.Mountains.Peak do
  @moduledoc """
  A Peak represents a mountain peak.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  code_interface do
    define_for PeakTracker.Mountains
    define :get, action: :read, get_by: [:slug]
    define :list, action: :read_paginated
  end

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
      prepare build(sort: [slug: :asc])

      pagination(
        required?: true,
        offset?: true,
        countable: true,
        keyset?: true,
        default_limit: 20
      )
    end
  end

  identities do
    identity(:slug_unique, [:slug])
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)

      constraints(
        min_length: 2,
        trim?: true,
        allow_empty?: false
      )
    end

    attribute :slug, :string do
      allow_nil?(false)
    end

    timestamps()
  end
end
