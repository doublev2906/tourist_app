defmodule TouristApp.Repo.Migrations.AddRestaurantModel do
  use Ecto.Migration

  def change do
    create table(:restaurants, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :restaurant_id, :string, primary_key: true
      add :cover_image_url, :string
      add :lat, :string
      add :lon, :string
      add :price, :float
      add :name, :string
      add :en_name, :string
      add :rating, :float
      add :image_url, :string
      add :review_count, :integer
      add :distance_from_center, :float
      add :extra_info, :map

      timestamps()
    end
  end
end
