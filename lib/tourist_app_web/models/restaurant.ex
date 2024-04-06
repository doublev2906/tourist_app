defmodule TouristApp.Restaurant do
  use Ecto.Schema

  alias TouristApp.{Repo}
  import Ecto.Changeset

  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "restaurants" do
    field :restaurant_id, :string
    field :cover_image_url, :string
    field :lat, :float
    field :lon, :float
    field :price, :float
    field :name, :string
    field :en_name, :string
    field :rating, :float
    field :image_url, :string
    field :review_count, :integer
    field :distance_from_center, :float
    field :extra_info, :map
    field :city_id, :string

    timestamps()
  end

  @doc false
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, [:restaurant_id, :cover_image_url, :lat, :lon, :price, :name, :en_name, :rating, :image_url, :review_count, :distance_from_center, :extra_info])
    |> validate_required([:restaurant_id, :id])
  end

  def from_json(json) do
    %{
      restaurant_id: Integer.to_string(json["restaurantId"]),
      cover_image_url: json["coverImgaeUrl"],
      lat: json["gglat"],
      lon: json["gglon"],
      price: json["price"],
      name: json["poiName"],
      en_name: json["englishName"],
      rating: json["rating"],
      image_url: hd(json["imgeUrls"]), # Assuming only the first image URL is used
      review_count: json["reviewCount"],
      distance_from_center: json["distancefromcenter"],
      extra_info: %{
        tags: json["tags"],
        icon: json["icon"],
        comment_info: json["commentInfo"],
        have_book: json["haveBook"]
      }
    }
  end

  def get_restaurant_by_city_id(city_id) do
    offset = 0
    limit = 10

    from(
      d in __MODULE__,
      where: d.city_id == ^city_id,
      offset: ^offset,
      limit: ^limit,
      order_by: [desc: d.rating],
      select: d
    ) 
    |> Repo.all()
    |> Enum.map(&Map.take(&1, [:restaurant_id, :id, :name, :rating, :cover_image_url, :city_id, :distance_from_center, :extra_info]))
  end
end
