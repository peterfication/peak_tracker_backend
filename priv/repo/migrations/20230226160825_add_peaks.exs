defmodule PeakTracker.Repo.Migrations.AddPeaks do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:peaks, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false
    end
  end

  def down do
    drop table(:peaks)
  end
end
