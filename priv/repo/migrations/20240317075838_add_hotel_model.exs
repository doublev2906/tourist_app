defmodule TouristApp.Repo.Migrations.AddHotelModel do
  use Ecto.Migration

  def change do
    create table(:hotels, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :hotel_id, :string, primary_key: true
      add :hotel_name, :string
      add :hotel_en_name, :string
      add :hotel_img, :string
      add :hotel_address, :string
      add :super_star, :float
      add :favority_count, :integer
      add :top_recommend, :boolean
      add :pay_type, :integer
      add :hour_earliest_arrive_time, :string
      add :hour_latest_arrive_time, :string
      add :price, :integer
      add :origin_price, :integer
      add :is_full_room, :boolean
      add :sign_in_note, :string
      add :hotel_multi_imgs, {:array, :string}
      add :hotel_decorate_info, :map
      add :hotel_star_info, :float
      add :comment_info, :map
      add :room_info, :map
      add :position_info, :map
      add :physic_room_map, :map
      add :extra_info, :map

      timestamps()
    end
  end
end
