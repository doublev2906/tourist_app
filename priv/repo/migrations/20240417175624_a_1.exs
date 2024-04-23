defmodule TouristApp.Repo.Migrations.A1 do
  use Ecto.Migration

  def change do
    alter table(:destinations) do
      add :category_keys, {:array, :string}
    end
  end
end
