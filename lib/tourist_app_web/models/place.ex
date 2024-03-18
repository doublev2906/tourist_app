defmodule TouristApp.Place do
  use TouristAppWeb, :model
  import TouristApp.{Repo}

  import Ecto.Query

  @primary_key false
  schema "places" do
    field :id, :binary_id, autogenerate: true, primary_key: true
    field :place_id, :string, primary_key: true
    field :name, :string
    field :address, :map
    field :lat, :float
    field :lon, :float
    field :extra_info, :map
    field :categories, {:array, :string}
    field :images, {:array, :string}

    timestamps()
  end

end