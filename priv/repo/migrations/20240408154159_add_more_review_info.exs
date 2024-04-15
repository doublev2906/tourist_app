defmodule TouristApp.Repo.Migrations.AddMoreReviewInfo do
  use Ecto.Migration

  def change do
    alter table(:reviews) do
      add :type, :string
      add :extra_info, :map
    end
  end
end
