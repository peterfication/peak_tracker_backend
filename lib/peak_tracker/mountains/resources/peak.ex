defmodule PeakTracker.Mountains.Peak do
  @moduledoc """
  A Peak represents a mountain peak.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ],
    notifiers: [
      Ash.Notifier.PubSub
    ]

  require Ecto.Query

  alias PeakTracker.Mountains.Scale

  @type t :: t()

  code_interface do
    define_for(PeakTracker.Mountains)
    define(:get, action: :read, get_by: [:slug])
    define(:get_by_osm_id, action: :read, get_by: [:osm_id])
    define(:list, action: :read_paginated)
    define(:create, action: :create)
    define(:update, action: :update)

    define :scale
    define :unscale
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
      prepare(build(sort: [slug: :asc]))

      pagination(
        required?: true,
        offset?: true,
        countable: true,
        keyset?: true,
        default_limit: 20
      )

      argument(
        :scaled_by_actor,
        :boolean,
        description: "Show only peaks scaled by the current actor (Not implemented yet)"
      )

      # filter(
      #   expr do
      #     is_nil(^arg(:representative_id)) or representative_id == ^arg(:representative_id)
      #   end
      # )
    end

    update :scale do
      accept []

      manual fn changeset, %{actor: actor} ->
        with {:ok, _} <- Scale.scale(changeset.data.id, actor: actor) do
          {:ok, changeset.data}
        end
      end
    end

    update :unscale do
      accept []

      manual fn changeset, %{actor: actor} ->
        scale =
          Ecto.Query.from(scale in Scale,
            where: scale.user_id == ^actor.id,
            where: scale.peak_id == ^changeset.data.id
          )

        PeakTracker.Repo.delete_all(scale)

        {:ok, changeset.data}
      end
    end
  end

  pub_sub do
    module PeakTrackerWeb.Endpoint
    prefix "peaks"

    publish :scale, ["scaled", :id]
    publish :unscale, ["unscaled", :id]
  end

  identities do
    identity(:slug_unique, [:slug])
    identity(:osm_id_unique, [:osm_id])
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

    attribute :osm_id, :integer do
      allow_nil?(false)
    end

    attribute :latitude, :float do
      allow_nil?(false)
    end

    attribute :longitude, :float do
      allow_nil?(false)
    end

    attribute :elevation, :integer do
      allow_nil?(false)
    end

    # Wikipedia slug in the format "<ISO country code>:<slug>"
    attribute :wikipedia, :string do
      allow_nil?(true)
    end

    # Wikidata ID in the format "Q<id>"
    #
    # Can be used to access wikidata information
    # E.g. https://www.wikidata.org/wiki/Q1
    attribute :wikidata_id, :string do
      allow_nil?(true)
    end

    # The Google Places ID, if it exists (has to be added manually)
    attribute :google_places_id, :string do
      allow_nil?(true)
    end

    timestamps()
  end

  relationships do
    has_many(:scales, PeakTracker.Mountains.Scale)
  end

  calculations do
    calculate :scaled_by_user, :boolean, expr(exists(scales, user_id == ^arg(:user_id))) do
      argument :user_id, :uuid do
        allow_nil? false
      end
    end
  end

  aggregates do
    count :scale_count, :scales
  end
end
