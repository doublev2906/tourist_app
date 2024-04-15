defmodule TouristAppWeb.DestinationController do
  use TouristAppWeb, :controller
  alias TouristApp.{Destination, Repo, TripApi, Review, Moment}

  def index(conn, params) do
    destination_id = params["id"]
    destination = Repo.get_by(Destination, %{id: destination_id}) 
    nearbyModuleList = TripApi.get_near_by_module(destination.destination_id)
    reviews = Review.get_reviews_by_place_id(destination.destination_id, "destination")
    moments = Moment.get_moments_by_destination_id(destination.destination_id) 
    json conn, %{success: true, data: %{nearbyModuleList: nearbyModuleList, reviews: reviews, moments: moments}}
  end

  def get_list_destination(conn, params) do
    destinations = Destination.get_all_destination(params)
    json conn, %{success: true, data: destinations}
  end

  
end