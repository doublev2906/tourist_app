defmodule TouristAppWeb.DestinationController do
  use TouristAppWeb, :controller
  alias TouristApp.{Destination, Repo, TripApi, Review, Moment, Tools, User}
  import Ecto.Query
  plug TouristApp.Auth when action in [:add_destination_review, :get_destination_of_user]

  def index(conn, params) do
    destination_id = params["id"]
    destination = Repo.get_by(Destination, %{id: destination_id}) 
    nearbyModuleList = TripApi.get_near_by_module(destination.destination_id)
    reviews = Review.get_reviews_by_place_id(destination.destination_id, "destination", limit: 20)
    moments = Moment.get_moments_by_destination_id(destination.destination_id) 
    json conn, %{success: true, data: %{nearbyModuleList: nearbyModuleList, reviews: reviews, moments: moments}}
  end

  def get_list_destination(conn, params) do
    destinations = Destination.get_all_destination(params)
    json conn, %{success: true, data: destinations}
  end

  def add_destination_review(conn, params) do
    user_id = conn.assigns[:user_id]
    params = Map.put(params, "user_id", user_id) |> Map.put("type", "destination")
    IO.inspect(Tools.to_atom_keys_map(params))
    Review.insert(Tools.to_atom_keys_map(params))

    json conn, %{success: true}
  end

  def get_destination_of_user(conn, _) do
    user = Repo.get_by(User, %{id: conn.assigns.user_id})
    destinations = Destination.get_destinations(user.favorite_destinations)
    json conn, %{success: true, data: destinations}
  end

  
end