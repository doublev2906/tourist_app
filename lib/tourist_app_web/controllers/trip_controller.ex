defmodule TouristAppWeb.TripController do
  use TouristAppWeb, :controller

  plug TouristApp.Auth

  alias TouristApp.{Trip, Tools, Destination}

  def index(conn, params) do
    trips = Trip.get_trips(%{"user_id" => conn.assigns[:user_id]}) |> Enum.map(&(Tools.schema_to_map(&1)))
    json conn, %{success: true, data: trips}
  end

  def create(conn, params) do
    params = Map.put(params, "user_id", conn.assigns[:user_id])
    trip = Trip.insert_trip(params) |> Map.take([:id])
    json conn, %{success: true, trip: trip}
  end

  def update(conn, params) do
    id = params["id"]
    change = params["change"] || %{}
    new_trip = Trip.update_trip(%{"id" => id, "change" => change})
    json conn, %{success: true, trip: Tools.schema_to_map(new_trip)}
  end

  def show(conn, params) do
    Trip.get_trip_by_id(params["id"])
    |> case do
      nil -> json conn, %{success: false, message: "Trip not found"}
      trip -> 
        IO.inspect(trip.list_destinations)
        list_destinations = Destination.get_destinations(trip.list_destinations || [])
        json conn, %{success: true, trip: Tools.schema_to_map(trip), list_destinations: list_destinations}

    end

  end
end