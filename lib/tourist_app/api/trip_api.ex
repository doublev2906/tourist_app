defmodule TouristApp.TripApi do
  import Ecto.Query

  alias TouristApp.{Repo, Tools}

  @default_header [
    {"authority", "www.trip.com"},
    {"accept", "application/json, text/plain, */*"},
    {"accept-language", "vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7,zh-CN;q=0.6,zh;q=0.5,fr-FR;q=0.4,fr;q=0.3"},
    {"content-type", "application/json"},
    {"origin", "https://vn.trip.com"},
    {"referer", "https://vn.trip.com/"},
    {"sec-ch-ua", "\"Chromium\";v=\"122\", \"Not(A:Brand\";v=\"24\", \"Google Chrome\";v=\"122\""},
    {"sec-ch-ua-mobile", "?0"},
    {"sec-ch-ua-platform", "\"macOS\""},
    {"sec-fetch-dest", "empty"},
    {"sec-fetch-mode", "cors"},
    {"sec-fetch-site", "same-site"},
    {"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"}
  ]

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

  def get_destination_detail(detail_url) do
    Tools.http_get(detail_url)
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
                          "appData" => appData
                        }
                      }
                    } ->
                      open_time = appData["openTimeCellVO"]
                      overview_data = Map.take(appData["overviewData"], ["basicInfo", "comment", "favorite", "imageInfo", "trafficInfo"])
                      position_info = appData["poiData"]
                      templateList = appData["templateListData"]["templateList"]
                      destination_near_by = Enum.find(templateList, fn t -> t["templateType"] == "search_nearby" end)
                      %{open_time: open_time, overview_data: overview_data, position_info: position_info, destination_near_by: destination_near_by}
                  end
          _ -> 
              :error
            
        end
    end
  end

  def get_near_by_module(destination_id, opts \\ []) do
    types = Keyword.get(opts, :types, [1, 2, 3, 4])
    module_list = Enum.map(types, fn type ->
      %{
        "count" => 20,
        "index" => 1,
        "quickFilterType" => "",
        "type" => type,
        "distance" => 20,
        "sortType" => 1
      }
    end)  
    
    url = "https://vn.trip.com/restapi/soa2/19913/getTripNearbyModuleList"
    data = %{
      "moduleList" => module_list,
      "poiId" => destination_id,
      "head" => %{
        "locale" => "vi-VN",
        "cver" => "3.0",
        "cid" => "1710425553277.8a25M5Eprc2q",
        "syscode" => "999",
        "sid" => "",
        "extension" => [
          %{"name" => "locale", "value" => "vi-VN"},
          %{"name" => "platform", "value" => "Online"},
          %{"name" => "currency", "value" => "VND"},
          %{"name" => "aid", "value" => ""}
        ]
      }
    }

    Tools.http_post(url, Poison.encode!(data), @default_header)
    |> case do
      %{
        "success" => true,
        "response" => %{
          "nearbyModuleList" => nearbyModuleList
        }
      } -> 
        nearbyModuleList
      _ ->
        []
      end
    
  end
end