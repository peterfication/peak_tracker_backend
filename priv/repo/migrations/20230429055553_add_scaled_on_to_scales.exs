defmodule PeakTracker.Repo.Migrations.AddScaledOnToScales do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:scales) do
      add :scaled_on, :date, null: true
    end

    execute """
      UPDATE scales SET scaled_on = DATE(inserted_at);
    """

    alter table(:scales) do
      modify :scaled_on, :date, null: false
    end

    drop_if_exists(
      unique_index(
        :scales,
        [:peak_id, :user_id],
        name: "scales_unique_user_and_peak_index"
      )
    )

    create(
      unique_index(
        :scales,
        [:user_id, :peak_id, :scaled_on],
        name: "scales_unique_user_and_peak_and_scaled_on_index"
      )
    )
  end

  def down do
    drop_if_exists(
      unique_index(
        :scales,
        [:user_id, :peak_id, :scaled_on],
        name: "scales_unique_user_and_peak_and_scaled_on_index"
      )
    )

    create(
      unique_index(
        :scales,
        [:peak_id, :user_id],
        name: "scales_unique_user_and_peak_index"
      )
    )

    alter table(:scales) do
      remove :scaled_on
    end
  end
end
