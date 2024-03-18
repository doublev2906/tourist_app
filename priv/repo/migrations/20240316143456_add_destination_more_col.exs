defmodule TouristApp.Repo.Migrations.AddDestinationMoreCol do
  use Ecto.Migration

  def change do
    alter table(:destinations) do
      add :coordinates, :map
      add :extra_info, :map

    end
  end
end
