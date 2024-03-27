defmodule Manage do
  
  alias TouristApp.{Tools, Repo, Place, CityInfo, Destination, Hotel, Restaurant}

  import Ecto.Query

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
  
  def test do
    Repo.get_by(Destination, %{id: "00029019-6b00-4501-89b7-04719f10bd89"})
    |> Ecto.Changeset.change(%{extra_info: %{tes: "sss"}})
  end

  def get_places_from_api() do

    categories = [
    "tourism.sights.place_of_worship.temple",
    "tourism.sights.tower",
    "tourism.sights.battlefield",
    "tourism.sights.archaeological_site",
    "tourism.sights.city_gate",
    "tourism.sights.bridge",
    "tourism.attraction",
    "entertainment.culture",
    "entertainment.museum",
    "entertainment.water_park",
    "entertainment.activity_park",
    "beach",
    "catering.restaurant.seafood",
    "catering.restaurant.vietnamese",
    "catering.bar"
    ]
    coordinates = %{
      latitude: 108.2062 ,
      longitude: 16.0479 
    }
    TouristApp.Api.GeoapifyApi.get_place(categories, coordinates, limit: 300, radius: 30000)
    |> case do
      %{
        "response" => %{
          "features" => features
        }
      } -> 
        Enum.map(features, fn %{"properties" => properties} -> 
          address = Map.take(properties, ["country", "city", "suburb", "quarter", "street", "formatted"])
          extra_info = Map.take(properties, ["opening_hours", "contact", "catering"])
          place = %{
            place_id: properties["place_id"],
            name: to_string(properties["name"]),
            address: address,
            lat: properties["lat"],
            lon: properties["lon"],
            extra_info: extra_info,
            categories: properties["categories"]
          }

          struct(Place, place)
          |> Repo.insert!

        end)
      res-> 
        IO.inspect(res)
    end
  end

  def get_district_info(idx \\ 1) do
    page_size = 10
    data = %{
      "districtId" => 100046,
      "pageIndex" => idx,
      "pageSize" => page_size,
      "aid" => "",
      "sid" => "",
      "head" => %{
        "cver" => "3.0",
        "cid" => "1710425553277.8a25M5Eprc2q",
        "syscode" => "999",
        "locale" => "vi-VN",
        "extension" => [
          %{
            "name" => "locale",
            "value" => "vi-VN"
          },
          %{
            "name" => "platform",
            "value" => "Online"
          },
          %{
            "name" => "currency",
            "value" => "VND"
          }
        ]
      }
    }

    url = "https://www.trip.com/restapi/soa2/23044/getHotDistrictPage"

    Tools.http_post(url, Poison.encode!(data), @default_header)
    |> case do
      %{
        "success" => true,
        "response" => %{
          "hotDistrictItemList" => item_list
        }
      } when is_list(item_list) ->
        Enum.with_index(item_list) 
        |> Enum.map(fn {item, index} -> 
          index_sort = (idx - 1) * page_size + index
          Repo.transaction(fn -> 
            city_info = %{
              id: to_string(item["districtId"]),
              name: item["name"],
              e_name: item["eName"],
              image_url: item["imageUrl"],
              index_sort: index_sort
            }
            struct(CityInfo, city_info)
            |> Repo.insert!
          end)
        end)
      res ->
        IO.inspect(res) 
      end

    if idx <= 3, do: get_district_info(idx + 1)

  end

  def get_all_destination() do
    from(
      c in CityInfo,
      select: c.id
    )
    |> Repo.all()
    |> Enum.map(fn id -> get_destination_by_city_id(id) end)
  end

  def get_all_hotels do
    from(
      c in CityInfo,
      select: c.city_id
    )
    |> Repo.all()
    |> Enum.map(fn id -> get_hotel_by_city_id(id) end)
  end

  def get_destination_by_city_id(id, idx \\ 1) do
    data = %{
      "head" => %{
        "extension" => [
          %{"name" => "platform", "value" => "Online"},
          %{"name" => "locale", "value" => "vi-VN"},
          %{"name" => "currency", "value" => "VND"}
        ],
        "cid" => "1710425553277.8a25M5Eprc2q"
      },
      "scene" => "gsDestination",
      "districtId" => id,
      "index" => idx,
      "count" => 20,
      "sortType" => 1,
      "returnModuleType" => "product",
      "filter" => %{
        "filterItems" => [],
        "coordinateFilter" => %{
          "coordinateType" => "wgs84",
          "latitude" => 0,
          "longitude" => 0
        },
        "itemType" => ""
      },
      "token" => "LDk4NzM4LDMyODYyMTQ4LDkwNjA1LDIwOTA1NjU2LDEzMzgyODAwOCwzODYyMjA4MSwyODM3ODIzNSwzODUzNDg0MiwxMzAzNjk0NjQsMTM2MjA5Njg3",
      "keyword" => nil,
      "cityId" => 0,
      "pageId" => "10650006153"
    }

    url = "https://vn.trip.com/restapi/soa2/19913/getTripAttractionList?x-traceID=1710425553277.8a25M5Eprc2q-1710434594684-1797999696"
    Tools.http_post(url, Poison.encode!(data), @default_header)
    |> case do
       %{
         "success" => true,
         "response" => %{
           "attractionList" => attraction_list
         }
       } ->
        Enum.map(attraction_list, fn %{"showType" => type, "card" => data} -> 
          Repo.transaction(fn -> 
            destination = map_to_destination(data, id, type)
          IO.inspect(destination)

            struct(Destination, destination)
            |> Repo.insert!
          end)
        end)
        
    end

    if idx <= 5, do: get_destination_by_city_id(id, idx + 1)
    
  end

  def get_hotel_by_city_id(id, idx \\ 1) do
    data = %{
      guideLogin: "T",
      search: %{
        sessionId: "553cbe35-14dc-292f-9e78-f579071d4b6f",
        preHotelCount: 0,
        preHotelIds: [],
        checkIn: "20240317",
        checkOut: "20240318",
        sourceFromTag: "",
        filters: [
          %{filterId: "17|1", value: "1", type: "17", subType: "2", sceneType: "17"},
          %{filterId: "80|0|1", value: "0", type: "80", subType: "2", sceneType: "80"},
          %{filterId: "29|1", value: "1|2", type: "29"}
        ],
        pageCode: 10320668148,
        location: %{
          geo: %{countryID: 111, provinceID: 0, cityID: String.to_integer(id), districtID: 0, oversea: true},
          coordinates: []
        },
        pageIndex: idx,
        pageSize: 10,
        needTagMerge: "T",
        roomQuantity: 1,
        orderFieldSelectedByUser: false,
        hotelId: 0,
        tripWalkDriveSwitch: "T",
        resultType: "CT",
        nearbyHotHotel: %{},
        recommendTimes: 0,
        crossPromotionId: "",
        travellingForWork: false
      },
      batchRefresh: %{batchId: "18e4b8dfbee1hp5oruve", batchSeqNo: 1},
      queryTag: "NORMAL",
      mapType: "GOOGLE",
      extends: %{
        crossPriceConsistencyLog: "",
        NewTaxDescForAmountshowtype0: "B",
        MealTagDependOnMealType: "T",
        MultiMainHotelPics: "T",
        enableDynamicRefresh: "F",
        isFirstDynamicRefresh: "T"
      },
      head: %{
        platform: "PC",
        clientId: "1710425553277.8a25M5Eprc2q",
        bu: "ibu",
        group: "TRIP",
        aid: "",
        sid: "",
        ouid: "",
        caid: "",
        csid: "",
        couid: "",
        region: "VN",
        locale: "vi-VN",
        timeZone: "7",
        currency: "VND",
        p: "17480444696",
        pageID: "10320668148",
        deviceID: "PC",
        clientVersion: "0",
        frontend: %{vid: "1710425553277.8a25M5Eprc2q", sessionID: "8", pvid: "1"},
        extension: [
          %{name: "cityId", value: id},
          %{name: "checkIn", value: "2024/03/17"},
          %{name: "checkOut", value: "2024/03/18"}
        ],
        tripSub1: "",
        qid: 880118040242,
        pid: "6628843c-4384-419a-8d88-31f6cca04243",
        hotelExtension: %{hotelUuidKey: "", hotelTestAb: "24f79d17d972b5bd8d9ff4b66bde68373f3a63da2fd97622a8a8af6145862d53"},
        cid: "1710425553277.8a25M5Eprc2q",
        traceLogID: "ffed99673fddc",
        ticket: "",
        deviceConfig: "L"
      }
    }
    

    url = "https://vn.trip.com/htls/getHotelList?testab=24f79d17d972b5bd8d9ff4b66bde68373f3a63da2fd97622a8a8af6145862d53&x-traceID=1710425553277.8a25M5Eprc2q-1710664585295-1974924300"

    Tools.http_post(url, Poison.encode!(data), @default_header)
    |> case do
       %{
         "success" => true,
         "response" => %{
           "hotelList" => hotel_list
         }
       } -> 
        Enum.map(hotel_list, fn h ->
          hotel = Hotel.from_json(h)
          Repo.transaction(fn -> struct(Hotel, hotel) |> Repo.insert! end)
        end)

      res -> IO.inspect(res)
    end

    if idx <= 5, do: get_hotel_by_city_id(id, idx + 1)
    
  end

  def map_to_destination(data, city_id, type) do
    %{
      destination_id: Integer.to_string(data["poiId"]),
      type: type,
      name: Map.get(data, "poiName"),
      e_name: Map.get(data, "poiEName"),
      subtitle_name: Map.get(data, "poiSubtitleName"),
      is_advertisement: Map.get(data, "isAdvertisement"),
      cover_image_url: Map.get(data, "coverImageUrl"),
      location: Map.get(data, "location"),
      price_info: Map.get(data, "priceInfo"),
      hot_score: String.to_float(Map.get(data, "hotScore", "0,0") |> String.replace(",", ".")),
      distance_str: Map.get(data, "distanceStr"),
      city_id: city_id,
      coordinates: %{
        "coordinate_type" => Map.get(data, "coordinate", %{})["coordinateType"],
        "latitude" => Map.get(data, "coordinate", %{})["latitude"],
        "longitude" => Map.get(data, "coordinate", %{})["longitude"]
      },
      extra_info: %{
        "comment_info" => %{
          "ta_comment_count" => Map.get(data, "commentInfo", %{})["taCommentCount"],
          "comment_count" => Map.get(data, "commentInfo", %{})["commentCount"],
          "comment_score" => Map.get(data, "commentInfo", %{})["commentScore"],
          "comment_content" => Map.get(data, "commentInfo", %{})["commentContent"],
          "comment_avatar" => Map.get(data, "commentInfo", %{})["commentAvatar"],
          "nick_name" => Map.get(data, "commentInfo", %{})["nickName"]
        },
        "is_from_favor" => Map.get(data, "isFromFavor"),
        "is_new_rank" => Map.get(data, "isNewRank"),
        "has_video" => Map.get(data, "hasVideo")
      }
    }
    
  end

  def add_city_id do
    from(c in CityInfo, select: c.id)
    |> Repo.all
    |> Enum.map(fn id -> get_destination_detail(id) end)
  end

  def get_destination_detail(id) do
    url = "https://www.trip.com/restapi/soa2/23044/getDestinationPageInfo.json"

    data = %{
      "districtId" => id,
      "moduleList" => [
        "classicRecommendHotel",
        "classicRecommendSight",
        "classicRecommendRestaurant",
        "toursAndTickets"
      ],
      "aid" => "",
      "sid" => "",
      "head" => %{
        "syscode" => "10000",
        "lang:" => "vi-VN",
        "cid" => "1710649624243.f55a5neUBa7J",
        "extension" => [
          %{"name" => "locale", "value" => "vi-VN"},
          %{"name" => "platform", "value" => "Online"},
          %{"name" => "currency", "value" => "VND"}
        ]
      }
    }

    Tools.http_post(url, Poison.encode!(data), @default_header)
    |> case do
       %{
         "success" => true,
         "response" => %{
            "moduleList" => module_list
         }
       } ->
        Enum.map(module_list, fn module ->
          case module do
            %{
              "typeName" => "classicRecommendHotel",
              "classicRecommendHotelModule" => %{
                "hotelList" => hotelList
              }
            } when is_list(hotelList) ->
              Enum.at(hotelList,0)
              |> case do
                %{"moreUrl" => url} ->
                  %URI{query: query} = URI.parse(url)
                  %{"city" => city} = URI.decode_query(query)
                  Repo.get_by(CityInfo, %{id: id})
                  |> Ecto.Changeset.change(%{city_id: city})
                  |> Repo.update!
                a -> IO.inspect(a)
                  
              end
            _ -> "test"
          end
        end)
        
      res -> IO.inspect(res)
    end
  end

  def get_all_restaurant() do
    from(
      c in CityInfo,
      select: c.id
    )
    |> Repo.all()
    |> Enum.map(fn id -> get_restaurant_by_city_id(id) end)
  end

  def get_restaurant_by_city_id(id, idx \\ 1) do

    data = %{
      head: %{
        cid: "1710425553277.8a25M5Eprc2q",
        extension: [
          %{name: "locale", value: "vi-VN"},
          %{name: "platform", value: "Online"},
          %{name: "currency", value: "VND"}
        ]
      },
      districtId: String.to_integer(id),
      sortType: "score",
      pageIndex: idx,
      pageSize: 9,
      lat: 0,
      lon: 0,
      tag: 0,
      filterType: 2,
      minPrice: 0,
      fromPage: nil
    }
  
    url = "https://vn.trip.com/restapi/soa2/18361/foodListSearch"

    Tools.http_post(url, Poison.encode!(data), @default_header)
    |> case do
      %{
        "success" => true,
        "response" => %{
          "results" => results
        }
      } ->
        Enum.map(results, fn item ->
          restaurant = Restaurant.from_json(item) |> Map.put(:city_id, id)
          struct(Restaurant, restaurant)
          |> Repo.insert!
        end)
      res -> IO.inspect(res)
    end

    if idx <= 5, do: get_restaurant_by_city_id(id, idx + 1)
    
  end

  def insert_all_city_location() do
    from(
      c in CityInfo,
      select: c
    )
    |> Repo.all()
    |> Enum.map(&(insert_city_location(&1)))
  end

  def insert_city_location(city) do
    data = %{
      "head" => %{
        "extension" => [
          %{"name" => "platform", "value" => "Online"},
          %{"name" => "locale", "value" => "vi-VN"},
          %{"name" => "currency", "value" => "VND"}
        ],
        "cid" => "1710425553277.8a25M5Eprc2q"
      },
      "scene" => "gsDestination",
      "districtId" => city.id,
      "index" => 1,
      "count" => 1,
      "sortType" => 1,
      "returnModuleType" => "product",
      "filter" => %{
        "filterItems" => [],
        "coordinateFilter" => %{
          "coordinateType" => "wgs84",
          "latitude" => 0,
          "longitude" => 0
        },
        "itemType" => ""
      },
      "token" => "LDk4NzM4LDMyODYyMTQ4LDkwNjA1LDIwOTA1NjU2LDEzMzgyODAwOCwzODYyMjA4MSwyODM3ODIzNSwzODUzNDg0MiwxMzAzNjk0NjQsMTM2MjA5Njg3",
      "keyword" => nil,
      "cityId" => 0,
      "pageId" => "10650006153"
    }

    url = "https://vn.trip.com/restapi/soa2/19913/getTripAttractionList?x-traceID=1710425553277.8a25M5Eprc2q-1710434594684-1797999696"
    Tools.http_post(url, Poison.encode!(data), @default_header)
    |> case do
       %{
         "success" => true,
         "response" => %{
           "districtInfo" => %{"coordinate" => coordinate}
         }
       } ->
        city
        |> Ecto.Changeset.change(%{coordinates: coordinate})
        |> Repo.update!
        res -> IO.inspect(res)
        
    end
    
  end


end