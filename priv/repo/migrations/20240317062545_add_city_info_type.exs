defmodule TouristApp.Repo.Migrations.AddCityInfoType do
  use Ecto.Migration

  def change do
    alter table(:city_info) do
      add :city_id, :string
    end
  end
end
