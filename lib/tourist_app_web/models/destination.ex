defmodule TouristApp.Destination do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "destinations" do
    field :destination_id, :string, primary_key: true
    field :name, :string
    field :e_name, :string
    field :subtitle_name, :string
    field :is_advertisement, :boolean, default: false
    field :cover_image_url, :string
    field :location, :string
    field :price_info, :map
    field :coordinates, :map
    field :extra_info, :map
    field :hot_score, :float
    field :distance_str, :string
    field :city_id, :string

    timestamps()
  end
end
