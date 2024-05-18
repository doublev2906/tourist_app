defmodule TouristApp.Repo.Migrations.A4 do
  use Ecto.Migration

  def change do
    create table(:moments_user_favorite, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, :uuid
      add :moment_id, :uuid

      timestamps()
    end
  end
end
