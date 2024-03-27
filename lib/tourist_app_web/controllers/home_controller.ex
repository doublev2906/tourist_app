defmodule TouristAppWeb.HomeController do
  use TouristAppWeb, :controller

  alias TouristApp.{Repo, Destination, CityInfo, Hotel, Restaurant}

  import Ecto.Query


  def index(conn, params) do

    city = CityInfo.get_city_by_coordinate(params)
    destinations = Destination.get_destination_by_city_id(city.id)
    hotels = Hotel.get_hotel_by_city_id(city.city_id)
    restaurants = Restaurant.get_restaurant_by_city_id(city.id)
    
    json conn, %{success: true, destinations: destinations, hotels: hotels, restaurants: restaurants}
  end

end