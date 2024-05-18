defmodule TouristAppWeb.UserController do
  use TouristAppWeb, :controller

  plug TouristApp.Auth when action in [:favorite_destination, :get_favorite_moments, :favorite_moment, :update_user_info]

  alias TouristApp.{User, MomentsUserFavorite, Repo, Moment}
  import Ecto.Query
  import Ecto.Changeset

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

  def get_favorite_moments(conn, params) do
    user_id = conn.assigns[:user_id]
    favorite_moment =
     from(
       f in MomentsUserFavorite,
       where: f.user_id == ^user_id,
       select: f.moment_id
     )
     |> Repo.all()
 
     json conn, %{success: true, data: favorite_moment}
     
  end

  def favorite_moment(conn, params) do
    is_favorited = params["is_favorited"]
    moment = Repo.get_by(Moment, %{id: params["moment_id"]})
    
    if is_favorited do
      new_like_count = moment.like_count - 1
      Repo.update(Ecto.Changeset.change(moment, like_count: new_like_count))
      data = Repo.get_by(MomentsUserFavorite, %{user_id: conn.assigns[:user_id], moment_id: params["moment_id"]})
      if data, do: Repo.delete(data)
    else
      new_like_count = moment.like_count + 1
      Repo.update(Ecto.Changeset.change(moment, like_count: new_like_count))
      params = Map.put(params, "user_id", conn.assigns[:user_id])
      MomentsUserFavorite.insert(params)
    end
    json conn, %{success: true}

  end

  def update_user_info(conn, params) do
    change = %{}
    change = if params["name"] do
      Map.put(change, :name, params["name"])
    else
      change
    end

    change = if params["phone_number"] do
      Map.put(change, :phone_number, params["phone_number"])
    else
      change
    end

    change = if params["avatar_url"] do
      Map.put(change, :avatar_url, params["avatar_url"])
    else
      change
    end
    
    Repo.get_by(User, %{id: conn.assigns[:user_id]})
    |> Ecto.Changeset.change(change)
    |> Repo.update()

    json conn, %{success: true}
  end
end