defmodule TouristApp.Moment do
  use TouristAppWeb, :model

  alias TouristApp.{Repo, User, CityInfo, Destination, MomentUserFavorite, Tools}
  import Ecto.Query
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "moment" do
    field :poi_id, :string, primary_key: true
    field :user_id, :binary_id
    field :content, :string
    field :cover_image, :string
    field :imageList, {:array, :string}, default: []
    field :like_info, :map, default: %{}
    field :extra_info, :map, default: %{}
    field :city_id, :string
    field :comment_count, :integer, default: 0
    field :like_count, :integer, default: 0

    timestamps()
  end


  def map_json(json_data, destination_id) do
    data = %{
      poi_id: destination_id || Integer.to_string(json_data["poiList"][0]["id"]),
      user_id: "f8a02f32-516f-459b-9c76-c7e255a45b4d",
      content: json_data["content"],
      cover_image: json_data["coverImage"]["url"],
      imageList: Enum.map(json_data["imageList"], &(&1["url"])),
    }
    struct(__MODULE__, data)
    |> TouristApp.Repo.insert!
  end

  def get_moments_by_destination_id(destination_id, opts \\ []) do
    offset = Keyword.get(opts, :offset, 0)
    limit = Keyword.get(opts, :limit, 20)
    moment_id = Keyword.get(opts, :moment_id, nil)
    query = from(
      m in __MODULE__,
      join: u in User,
      on: m.user_id == u.id,   
      where: m.poi_id == ^destination_id,
      order_by: [desc: m.inserted_at],
      limit: ^limit,
      offset: ^offset,
      select: %{
        id: m.id,
        poi_id: m.poi_id, 
        content: m.content, 
        cover_image: m.cover_image, 
        imageList: m.imageList, 
        like_info: m.like_info, 
        extra_info: m.extra_info,
        like_count: m.like_count,
        comment_count: m.comment_count,
        inserted_at: m.inserted_at,
        from: %{
          id: u.id,
          name: u.name,
          avatar_url: u.avatar_url
        }
      }
    )
    query = if moment_id, do: from(m in query, where: m.id != ^moment_id), else: query
    TouristApp.Repo.all(query)
  end

  def insert_moment_city_id() do
    from(
      m in __MODULE__,
      select: m
    )
    |> Repo.all()
    |> Enum.map(fn m ->
      from(
        d in Destination,
        where: d.destination_id == ^m.poi_id,
      )
      |> limit(1)
      |> Repo.one()
      |> case do
        nil ->
          nil
        destination ->
         Repo.update!(Ecto.Changeset.change(m, %{city_id: destination.city_id}))
      end
    end)
  end

  def get_moments_by_city_id(city_id, opts \\ []) do
    offset = Keyword.get(opts, :offset, 0)
    limit = Keyword.get(opts, :limit, 10)
    from(
      m in __MODULE__,
      where: m.city_id == ^city_id,
      join: u in User,
      on: m.user_id == u.id,   
      order_by: [desc: m.id],
      offset: ^offset,
      limit: ^limit,
      select: %{
        id: m.id,
        poi_id: m.poi_id, 
        content: m.content, 
        cover_image: m.cover_image, 
        imageList: m.imageList, 
        like_info: m.like_info, 
        extra_info: m.extra_info,
        from: %{
          id: u.id,
          name: u.name
        }
      }
    ) 
    |> Repo.all()
  end

  def insert(moment) do
    struct(__MODULE__, moment)
    |> Repo.insert!
  end


  def get_moment_of_user(user_id) do
    from(
      m in __MODULE__,
      join: d in Destination,
      on: m.poi_id == d.destination_id,
      where: m.user_id == ^user_id,
      order_by: [desc: m.inserted_at],
      select: %{data: m, destination: d}
    )
    |> Repo.all()
    # |> IO.inspect()
  end
end