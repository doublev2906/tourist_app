defmodule TouristApp.CityInfo do
  use TouristAppWeb, :model

  import TouristApp.{Repo}

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
end