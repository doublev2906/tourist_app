defmodule TouristAppWeb.CityController do
  use TouristAppWeb, :controller

  alias TouristApp.{CityInfo, Repo}

  import Ecto.Query

  def get_host_place(conn, params) do
    data = from(
      c in CityInfo,
      order_by: c.index_sort,
      limit: 10,
      offset: 0,
    ) 
    |> Repo.all()
    |> Enum.map(&(Map.take(&1, [:id, :name, :e_name, :image_url, :coordinates, :extra_info])))

    json conn, %{success: true, data: data}
  end
end