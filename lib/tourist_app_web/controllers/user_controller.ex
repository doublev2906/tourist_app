defmodule TouristAppWeb.UserController do
  use TouristAppWeb, :controller

  plug TouristApp.Auth when action in [:favorite_destination]

  alias TouristApp.{User}

  def login(conn, params) do
    User.verify_user(params)
    |> case do
      {:ok, user} ->
        json conn, %{user_data: Map.merge(user, User.create_token(user)), success: true, message: "Sign in successfully"}
      {:error, message} ->
        json conn, %{success: false, message: message}
    end
  end


  def sign_up(conn, params) do
    User.create_user(params)
    |> case do
      {:error, message} -> json conn, %{success: false, message: message}
      user -> json conn, %{user_data: Map.merge(user, User.create_token(user)), success: true, message: "Sign up successfully"}
    end
  end

  def favorite_destination(conn, params) do
    user_id = conn.assigns[:user_id]
    list_destinations = params["list_destinations"]

    User.update_favorite_destination(user_id, list_destinations)

    json conn, %{success: true}
  end
end