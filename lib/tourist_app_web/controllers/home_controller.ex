defmodule TouristAppWeb.HomeController do
  use TouristAppWeb, :controller

  alias TouristApp.{Repo, Destination, CityInfo, Hotel, Restaurant, KlookApi, TripApi}

  import Ecto.Query


  def index(conn, params) do

    data = TripApi.get_destination_detail("https://vn.trip.com/travel-guide/attraction/hanoi/hoan-kiem-lake-78921/") 
    
    json conn, %{success: true, data: data}
  end

  def get_destinations(conn, params) do
    city = CityInfo.get_city_by_coordinate(params)
    offset = params["offset"] || 0  
    limit = params["limit"] || 10
    destinations = Destination.get_destination_by_city_id(city.id, offset: offset, limit: limit)

    json conn, %{success: true, city_id: city.id ,destinations: destinations}
  end

  def get_activities(conn, params) do
    KlookApi.get_tour()
    |> case do
      data -> json conn, %{success: true, data: data}
      :error -> json conn, %{success: false}
    end
    
  end

end