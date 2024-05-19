defmodule TouristApp.Repo.Migrations.A7 do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION fuzzystrmatch"
  end

  def down do
    execute "DROP EXTENSION fuzzystrmatch"
  end
end
