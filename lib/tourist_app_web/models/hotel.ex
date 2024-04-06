defmodule TouristApp.Hotel do
  use Ecto.Schema

  alias TouristApp.{Repo}

  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "hotels" do
    field :hotel_id, :string, primary_key: true
    field :hotel_name, :string
    field :hotel_en_name, :string
    field :hotel_img, :string
    field :hotel_address, :string
    field :super_star, :float
    field :favority_count, :integer
    field :top_recommend, :boolean
    field :pay_type, :integer
    field :hour_earliest_arrive_time, :string
    field :hour_latest_arrive_time, :string
    field :price, :integer
    field :origin_price, :integer
    field :is_full_room, :boolean
    field :sign_in_note, :string
    field :hotel_multi_imgs, {:array, :string}
    field :hotel_decorate_info, :map
    field :hotel_star_info, :float
    field :comment_info, :map
    field :room_info, :map
    field :position_info, :map
    field :physic_room_map, :map
    field :extra_info, :map

    timestamps()
  end

  def map_image(images) do
    Enum.reduce(images, [], fn imgs, acc1 -> 
      acc1 ++ Enum.reduce(imgs, [], fn img, acc2 ->
        acc2 ++ [img["url"]]
      end)
    end)
  end

  def parse_float(value) do
    c_value = "#{value}"
    {num, _} = Float.parse c_value
    num
  end

  def parse_price(value) when is_integer(value), do: value
  def parse_price(_), do: nil

  # def parse_float(nil), do: 0.0

  def from_json(json) do
    %{
      hotel_id: Integer.to_string(json["hotelBasicInfo"]["hotelId"]),
      hotel_name: json["hotelBasicInfo"]["hotelName"],
      hotel_en_name: json["hotelBasicInfo"]["hotelEnName"],
      hotel_img: json["hotelBasicInfo"]["hotelImg"],
      hotel_address: json["hotelBasicInfo"]["hotelAddress"],
      super_star: parse_float(json["hotelBasicInfo"]["superStar"]),
      favority_count: json["hotelBasicInfo"]["favorityCount"],
      top_recommend: json["hotelBasicInfo"]["topRecommend"],
      pay_type: json["hotelBasicInfo"]["payType"],
      hour_earliest_arrive_time: json["hotelBasicInfo"]["hourEarliestArriveTime"],
      hour_latest_arrive_time: json["hotelBasicInfo"]["hourLatestArriveTime"],
      price: parse_price(json["hotelBasicInfo"]["price"]),
      origin_price: parse_price(json["hotelBasicInfo"]["originPrice"]),
      is_full_room: json["hotelBasicInfo"]["isFullRoom"],
      sign_in_note: json["hotelBasicInfo"]["signInNote"],
      hotel_multi_imgs: map_image(((json["hotelBasicInfo"]["hotelMultiImgs"] || []))),
      hotel_decorate_info: %{},
      hotel_star_info: parse_float(json["hotelStarInfo"]["star"]),
      comment_info: json["commentInfo"],
      room_info: json["roomInfo"],
      position_info: json["positionInfo"],
      physic_room_map: %{},
      extra_info: %{}
    }
  end

  def get_hotel_by_city_id(city_id, opts \\ []) do
    offset = Keyword.get(opts, :offset, 0)
    limit = Keyword.get(opts, :limit, 10)

    a = from(
      h in __MODULE__,
      where: fragment("?->>'cityId' = ?", h.position_info, ^"#{city_id}"),
      order_by: [desc: h.hotel_star_info],
      distinct: h.hotel_id,
      offset: ^offset,
      limit: ^limit,
      select: h
    ) 
    |> Repo.all()
    |> Enum.map(&(Map.take(&1, [:hotel_id, :hotel_name, :hotel_star_info, :position_info, :extra_info, :hotel_img, :hotel_address, :price, :comment_info])))
    
  end
end
