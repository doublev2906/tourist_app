defmodule TouristApp.Repo.Migrations.Review1 do
  use Ecto.Migration

  def change do
    alter table :moment do
      add :extra_info, :map
    end
  end
end
