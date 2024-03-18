defmodule TouristApp.Repo.Migrations.AddPlacesModel do
  use Ecto.Migration

  def change do
    create table(:places, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :place_id, :string, primary_key: true
      add :name, :string
      add :address, :map
      add :lat, :float
      add :lon, :float 
      add :extra_info, :map
      add :categories, {:array, :string}

      timestamps()
    end
  end

  def down do
    drop table("places")
  end
end
