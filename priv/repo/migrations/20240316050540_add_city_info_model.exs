defmodule TouristApp.Repo.Migrations.AddCityInfoModel do
  use Ecto.Migration

  def change do
    create table(:city_info, primary_key: false) do
      add :id, :string, primary_key: true
      add :type , :string
      add :name, :string
      add :e_name, :string
      add :image_url, :string
      add :coordinates, :map, default: %{}
      add :extra_info, :map, default: %{}

      timestamps()

    end
  end
end
