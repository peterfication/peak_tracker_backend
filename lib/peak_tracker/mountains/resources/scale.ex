defmodule PeakTracker.Mountains.Scale do
  @moduledoc """
  A Scale marks a peak as scaled by a user.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  @type t :: t()

  code_interface do
    define_for(PeakTracker.Mountains)
    define(:scale, args: [:peak_id])
  end

  postgres do
    table("scales")
    repo(PeakTracker.Repo)

    references do
      reference :peak do
        on_delete(:delete)
      end

      reference :user do
        on_delete(:delete)
      end
    end
  end

  actions do
    defaults([:read, :destroy])

    create :scale do
      upsert?(true)
      upsert_identity(:unique_user_and_peak_and_scaled_on)

      argument :peak_id, :uuid do
        allow_nil?(false)
      end

      change(set_attribute(:peak_id, arg(:peak_id)))
      change(set_attribute(:scaled_on, DateTime.to_date(DateTime.utc_now())))
      change(relate_actor(:user))
    end
  end

  identities do
    identity(:unique_user_and_peak_and_scaled_on, [:user_id, :peak_id, :scaled_on])
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:scaled_on, :date) do
      allow_nil?(false)
    end

    timestamps()
  end

  relationships do
    belongs_to :user, PeakTracker.Accounts.User do
      api(PeakTracker.Accounts)
      allow_nil?(false)
    end

    belongs_to :peak, PeakTracker.Mountains.Peak do
      allow_nil?(false)
    end
  end
end
