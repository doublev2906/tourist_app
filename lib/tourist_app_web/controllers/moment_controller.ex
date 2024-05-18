defmodule TouristAppWeb.MomentController do
  use TouristAppWeb, :controller
  alias TouristApp.{Moment, Destination, Repo, User, Tools, MomentComment}
  plug TouristApp.Auth when action in [:create, :create_comment, :get_user_moments]

  import Ecto.Query
  import Ecto.Changeset


  def index(conn, params) do
    limit = params["limit"] || 10
    offset = params["offset"] || 0
    user_id = params["user_id"] || nil
    
    query = from(
      m in Moment,
      join: d in Destination,
      on: m.poi_id == d.destination_id,
      order_by: [desc: m.inserted_at],
      limit: ^limit,
      offset: ^offset,
      select: %{data: m, destination: d}
    )

    query = if user_id, do: from(m in query, where: m.user_id != ^user_id), else: query

    
    data = Repo.all(query)
    |> Enum.map(fn %{data: m, destination: d} -> 
      user = Repo.get_by(User, %{id: m.user_id})
      %{
        moment: Tools.schema_to_map(m),
        destination: Tools.schema_to_map(d),
        user: Tools.schema_to_map(user)
      }
    end)

    json conn, %{success: true, data: data}

  end

  def create(conn, params) do
    user_id = conn.assigns[:user_id]
    params = Map.put(params, "user_id", user_id)
    moment = Moment.insert(Tools.to_atom_keys_map(params))
    json conn, %{success: true, moment: Tools.schema_to_map(moment)}
  end

  def show(conn, params) do
    moment_id = params["id"]
    moment = Repo.get_by(Moment, %{id: moment_id})
    related_moment = Moment.get_moments_by_destination_id(moment.poi_id, moment_id: moment.id, limit: 4)
    moment_comments = MomentComment.get_data(%{"moment_id" => moment_id, "limit" => 2})
    json conn, %{success: true, data: %{related_moment: related_moment, moment_comments: moment_comments}}
  end

  def create_comment(conn, params) do
    user_id = conn.assigns[:user_id]
    params = Map.put(params, "user_id", user_id)
    params = Map.put(params, "moment_id", params["id"])
    moment = Repo.get_by(Moment, %{id: params["id"]})
    new_comment_count = moment.comment_count + 1
    Repo.update(Ecto.Changeset.change(moment, comment_count: new_comment_count))

    {:ok, moment_comment} = MomentComment.insert(params)
    json conn, %{success: true, moment_comment: Tools.schema_to_map(moment_comment)}
  end

  def get_user_moments(conn, _) do
    data = 
      Moment.get_moment_of_user(conn.assigns[:user_id])
      |> Enum.map(fn %{data: m, destination: d} -> 
        %{
          moment: Tools.schema_to_map(m),
          destination: Tools.schema_to_map(d),
        }
      end)
    json conn, %{success: true, data: data}
  end
end