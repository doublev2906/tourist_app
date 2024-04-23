defmodule TouristApp.Repo.Migrations.AddTripsModel do
  use Ecto.Migration

  def change do
    alter table(:destinations) do
      add :categories, {:array, :string}
    end
  end
end
