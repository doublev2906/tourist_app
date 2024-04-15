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
    |> Enum.map(&Map.take(&1, [:id, :destination_id, :name, :subtitle_name, :hot_score, :cover_image_url, :city_id, :distance_str, :extra_info]))
  end

  def get_near_by_destinations(nil), do: []

  def get_all_destination(params) do
    offset = params["offset"] || 0
    limit = params["limit"] || 10
    city_ids = params["city_ids"]
    search = params["search"]
    lat = params["lat"] || 21.040085
    lon = params["long"] || 105.7814983

    query = from(
      d in __MODULE__,
      join: c in CityInfo, on: d.city_id == c.id,
      distinct: d.destination_id,
      select: %{ 
        id: d.id, 
        name: d.name,
        cover_image_url: d.cover_image_url, 
        city_id: d.city_id, 
        city_name: c.name,
        distance_str: d.distance_str, 
        extra_info: d.extra_info,
        hot_score: d.hot_score,
        distance: fragment("calculate_distance((sd0.coordinates -> 'latitude')::numeric, (sd0.coordinates -> 'longitude')::numeric, ?, ?, 'K')::float8", ^lat, ^lon)
      }
    )

    order_by = if params["order_by"] == "distance" do
      [desc: :distance]
    else
      [desc: :hot_score]
    end

    query = if city_ids do
      city_ids = String.split(city_ids, ",")
      from(
        d in query,
        where: d.city_id in ^city_ids
      )
    else
      query
    end

    query = if search do
      from(
        d in query,
        where: ilike(d.name, ^"%#{search}%")
      )
    else
      query
    end

    from(
      s in subquery(query),
      order_by: ^order_by,
      limit: ^limit,
      offset: ^offset
    )|> Repo.all
  end
end
