defmodule TouristApp.Repo.Migrations.A6 do
  use Ecto.Migration

  def change do
    alter table(:moment) do
      add :comment_count, :integer, default: 0
      add :like_count, :integer, default: 0
    end
  end
end
