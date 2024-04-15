defmodule TouristApp.Repo.Migrations.AddReviewTable do
  use Ecto.Migration

  def change do
    create table(:moment, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :poi_id, :string, primary_key: true
      add :user_id, :string
      add :content, :string
      add :cover_image, :string
      add :imageList, {:array, :string}
      add :like_info, :map

      timestamps()
    end
  end
end
