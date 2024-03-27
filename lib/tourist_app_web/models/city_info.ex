defmodule TouristApp.CityInfo do
  use TouristAppWeb, :model

  alias TouristApp.{Repo, Tools}

  import Ecto.Query

  @primary_key false
  schema "city_info" do
    field :id, :string, primary_key: true
    field :type , :string
    field :city_id , :string
    field :name, :string
    field :e_name, :string
    field :image_url, :string
    field :index_sort, :integer
    field :coordinates, :map, default: %{}
    field :extra_info, :map, default: %{} 

    timestamps()
  end


  def get_city_by_coordinate(%{"latitude" => latitude, "longitude" => longitude} = data) do
    latitude = String.to_float(latitude)
    longitude = String.to_float(longitude)
    from(
      c in __MODULE__,
      select: c
    )
    |> Repo.all()
    |> Enum.map(fn %__MODULE__{coordinates: coordinates } = city -> 
      distance = Tools.haversine_distance(coordinates, %{"latitude" => latitude, "longitude" => longitude}) |> round()
      Map.take(city, [:id, :city_id])
      |> Map.put(:distance, distance)
    end)
    |> Enum.sort_by(fn %{distance: distance} -> distance end)
    |> Enum.at(0)
  end

  def get_city_by_coordinate(_), do: nil

end