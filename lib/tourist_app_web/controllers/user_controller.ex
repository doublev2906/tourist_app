defmodule TouristAppWeb.UserController do
  use TouristAppWeb, :controller

  alias TouristApp.{User}

  def login(conn, params) do
    User.verify_user(params)
    |> case do
      {:ok, user} ->
        json conn, Map.merge(%{user_data: user, success: true, message: "Login successfully"}, User.create_token(user))
      {:error, message} ->
        json conn, %{success: false, message: message}
    end
  end


  def sign_up(conn, params) do
    User.create_user(params)
    |> case do
      {:error, message} -> json conn, %{success: false, message: message}
      user -> json conn, Map.merge(%{user_data: user, success: true, message: "Sign up successfully"}, User.create_token(user))
    end
  end
end