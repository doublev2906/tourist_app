defmodule TouristAppWeb.HomeController do
  use TouristAppWeb, :controller

  alias TouristApp.{Repo, Destination, CityInfo, Hotel, Restaurant, KlookApi}

  import Ecto.Query


  def index(conn, params) do
    city = CityInfo.get_city_by_coordinate(params)
    destinations = Destination.get_destination_by_city_id(city.id)
    hotels = Hotel.get_hotel_by_city_id(city.city_id)
    restaurants = Restaurant.get_restaurant_by_city_id(city.id)
    
    json conn, %{success: true, destinations: destinations, hotels: hotels, restaurants: restaurants}
  end

  def get_destinations(conn, params) do
    city = CityInfo.get_city_by_coordinate(params)
    offset = params["offset"] || 0  
    limit = params["limit"] || 10
    destinations = Destination.get_destination_by_city_id(city.id, offset: offset, limit: limit)

    json conn, %{success: true, destinations: destinations}
  end

  def get_activities(conn, params) do
    KlookApi.get_tour()
    |> case do
      data -> json conn, %{success: true, data: data}
      :error -> json conn, %{success: false}
    end
    
  end

end