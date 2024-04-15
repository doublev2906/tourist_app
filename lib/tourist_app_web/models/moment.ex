defmodule TouristApp.Moment do
  use TouristAppWeb, :model

  alias TouristApp.{Repo, User, CityInfo, Destination}
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

  def get_moments_by_destination_id(destination_id) do
    from(
      m in __MODULE__,
      join: u in User,
      on: m.user_id == u.id,   
      where: m.poi_id == ^destination_id,
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
    |> TouristApp.Repo.all()
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
end