defmodule TouristAppWeb.CityController do
  use TouristAppWeb, :controller

  alias TouristApp.{CityInfo, Repo, TripApi, Destination, Hotel, Restaurant, Tools}

  import Ecto.Query

  def get_host_place(conn, params) do
    data = from(
      c in CityInfo,
      order_by: c.index_sort,
      limit: 10,
      offset: 0,
    ) 
    |> Repo.all()
    |> Enum.map(&(Map.take(&1, [:id, :name, :e_name, :image_url, :coordinates, :extra_info])))

    json conn, %{success: true, data: data}
  end

  def get_city_detail(conn, params) do
    city_id = params["city_id"]

    city = Repo.get_by(CityInfo, %{id: city_id}) 
    trip_city_info = TripApi.get_trip_city_detail(city.extra_info["jump_url"])
    destination = Destination.get_destination_by_city_id(city_id)
    hotel = Hotel.get_hotel_by_city_id(city.city_id)
    restaurant = Restaurant.get_restaurant_by_city_id(city_id)
    city_near_by = get_city_near_by(city)

    json conn, %{success: true, city_info: trip_city_info, destination: destination, hotel: hotel, restaurant: restaurant, city_near_by: city_near_by}
  end

  defp get_city_near_by(city) do
    from(
      c in CityInfo,
      select: %{id: c.id, name: c.name, e_name: c.e_name, image_url: c.image_url, coordinates: c.coordinates, extra_info: c.extra_info}
    ) 
    |> Repo.all()
    |> Enum.filter(&(&1.id != city.id))
    |> Enum.map(&(Map.put(&1, :distance, Tools.haversine_distance(city.coordinates, &1.coordinates))))
    |> Enum.sort_by(fn %{distance: distance} -> distance end)
    |> Enum.take(10)
    
  end
end