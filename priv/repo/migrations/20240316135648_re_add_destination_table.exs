defmodule TouristApp.Repo.Migrations.ReAddDestinationTable do
  use Ecto.Migration

  def change do
    create table(:destinations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :destination_id, :string, primary_key: true
      add :name, :string
      add :e_name, :string
      add :subtitle_name, :string
      add :is_advertisement, :boolean, default: false
      add :cover_image_url, :string
      add :location, :string
      add :price_info, :map
      add :hotScore, :string
      add :distance_str, :string
      add :city_id, :string
      add :coordinates, :map
      add :extra_info, :map
      
      timestamps()

    end
  end
end
