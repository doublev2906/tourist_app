defmodule TouristApp.Repo.Migrations.A2 do
  use Ecto.Migration

  def change do
    create table(:trips, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, :uuid
      add :name, :text
      add :list_destinations, {:array, :string}
      add :start_at, :date
      add :end_at, :date
      add :destinations_comment, :map
      add :destinations_plan, :map
      
      timestamps()
    end
  end
end
