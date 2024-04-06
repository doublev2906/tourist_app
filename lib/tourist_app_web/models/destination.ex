defmodule TouristApp.Destination do

  alias TouristApp.{Repo, CityInfo}

  use Ecto.Schema

  import Ecto.Query

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

  def get_destination_by_city_id(city_id, opts \\ []) do
    offset = opts[:offset] || 0
    limit = opts[:limit] || 10

    from(
      d in __MODULE__,
      where: d.city_id == ^city_id,
      offset: ^offset,
      limit: ^limit,
      order_by: [desc: d.hot_score],
      select: d
    ) 
    |> Repo.all()
    |> Enum.map(&Map.take(&1, [:id, :destination_id, :name, :subtitle_name, :hot_score, :cover_image_url, :city_id, :distance_str]))
  end

  def get_near_by_destinations(nil), do: []
end
