defmodule TouristApp.Repo.Migrations.A5 do
  use Ecto.Migration

  def change do
    create table(:moment_comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, :uuid
      add :moment_id, :uuid
      add :content, :text

      timestamps()
    end
  end
end
