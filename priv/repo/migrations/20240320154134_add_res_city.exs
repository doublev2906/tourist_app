defmodule TouristApp.Repo.Migrations.AddResCity do
  use Ecto.Migration

  def change do
    alter table :restaurants do
      add :city_id, :string
    end
  end
end
