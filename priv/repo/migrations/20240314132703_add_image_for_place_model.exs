defmodule TouristApp.Repo.Migrations.AddImageForPlaceModel do
  use Ecto.Migration

  def change do
    alter table(:places) do
      add :images, {:array, :string}
    end
  end
end
