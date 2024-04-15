defmodule TouristApp.Repo.Migrations.AddDestinationReview do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :place_id, :string
      add :user_id, :string
      add :content, :text
      add :images, {:array, :string}
      add :rating, :float

      timestamps()
    end
  end
end
