defmodule TouristApp.TripApi do
  import Ecto.Query

  alias TouristApp.{Repo, Tools}

  def get_trip_city_detail(jump_url) do
    jump_url = jump_url
              |> String.replace("travel-guide/", "travel-guide/destination/")
    url = "https://vn.trip.com#{jump_url}?locale=vi-VN&curr=VND"

    Tools.http_get(url)
    |> case do
      %{
        "success" => true,
        "response" => response
      } -> 
        Floki.parse_document(response)
        |> case do
          {:ok, html} ->
            next_data = Floki.find(html, "#__NEXT_DATA__")
            {_, _, children_nodes} = Enum.at(next_data, 0)
            data = Jason.decode!(Enum.at(children_nodes, 0))
                  |> case do
                    %{
                      "props" => %{
                        "pageProps" => %{
                          "moduleList" => moduleList
                        }
                      }
                    } ->
                      moduleList
                      |> Enum.filter(&(&1["type"] == 27))
                      |> Enum.at(0)
                  end
          _ -> 
              :error
            
        end
    end
  end
end