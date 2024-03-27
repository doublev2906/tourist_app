defmodule TouristApp.KlookApi do

  alias TouristApp.{Tools}

  import Ecto.Query

  @city [
    %{id: 33, city_name: "TP Hồ Chí Minh", trip_id: 434},
    %{id: 74, city_name: "Đà Nẵng", trip_id: 669},
    %{id: 75, city_name: "Hội An", trip_id: 668},
    %{id: 34, city_name: "Hà Nội", trip_id: 181},
    %{id: 208, city_name: "Nha Trang", trip_id: 670},
    %{id: 207, city_name: "Đà Lạt", trip_id: 1393},
    %{id: 486, city_name: "Halong", trip_id: 1524623},
    %{id: 130, city_name: "Phú Quốc", trip_id: 24779},
    %{id: 35, city_name: "Huế", trip_id: 667},
    %{id: 290, city_name: "Sapa", trip_id: 1590136},
    %{id: 402, city_name: "Quy Nhơn", trip_id: 24728},
    %{id: 556, city_name: "Mũi Né - Phan Thiết", trip_id: 1218},
    %{id: 555, city_name: "Cần Thơ - ĐB Sông Cửu Long", trip_id: 24737},
    %{id: 510, city_name: "Đồng Hới - Quảng Bình", trip_id: 24726},
    %{id: 549, city_name: "Vũng Tàu", trip_id: 1389},
    %{id: 27791, city_name: "Côn Đảo", trip_id: 24761}
  ]

  @category data = [
    %{
      "id" => 3,
      "name" => "Công viên giải trí",
    },
    %{
      "id" => 4,
      "name" => "Bảo tàng",
    },
    %{
      "id" => 116,
      "name" => "Công viên & Vườn bách thảo",
    },
    %{
      "id" => 117,
      "name" => "Sở thú & Thuỷ cung",
      
    },
    %{
      "id" => 6,
      "name" => "Cáp treo",
    },
    %{
      "id" => 158,
      "name" => "Đài quan sát",
    },
    %{
      "id" => 7,
      "name" => "Di tích lịch sử",
    },
    %{
      "id" => 159,
      "name" => "Khu vui chơi",
    },
    %{
      "id" => 28,
      "name" => "Vui chơi trong nhà",
    },
    %{
      "id" => 8,
      "name" => "Vé tham quan",
    },
    %{
      "id" => 9,
      "name" => "Tour",
      "children" => [
        %{"id" => 10, "name" => "Tour trong ngày",  },
        %{"id" => 14, "name" => "Tour đi thuyền",  },
        %{"id" => 11, "name" => "Hop on hop off",  },
        %{"id" => 29, "name" => "Tour ẩm thực",  },
        %{"id" => 13, "name" => "Trải nghiệm trên không",  },
        %{"id" => 127, "name" => "Tour nhiều ngày",  },
        %{"id" => 162, "name" => "Đi bộ leo núi",  },
        %{"id" => 163, "name" => "Tour mua sắm",  }
      ]
    },
    %{
      "id" => 164,
      "name" => "Du thuyền",
      
      "children" => [%{"id" => 165, "name" => "Du thuyền ngắm cảnh",  }]
    },
    %{
      "id" => 20,
      "name" => "Massage & Suối nước nóng",
      
      "children" => [
        %{"id" => 21, "name" => "Spa & Massage",  },
        %{"id" => 23, "name" => "Suối nước nóng",  }
      ]
    },
    %{
      "id" => 121,
      "name" => "Hoạt động dưới nước",
      
      "children" => [
        %{"id" => 123, "name" => "Lặn ống thở & Lặn bình dưỡng khí",  },
        %{"id" => 125, "name" => "Chèo bè",  },
        %{"id" => 168, "name" => "Chèo ván",  },
        %{"id" => 169, "name" => "Thuê thuyền",  },
        %{"id" => 124, "name" => "Lướt sóng",  },
        %{"id" => 161, "name" => "Vé bãi biển/resort",  }
      ]
    },
    %{
      "id" => 15,
      "name" => "Phiêu lưu & Khám phá thiên nhiên",
      
      "children" => [
        %{"id" => 174, "name" => "Leo núi",  },
        %{"id" => 175, "name" => "Trượt zipline",  },
        %{"id" => 176, "name" => "Dù lượn",  },
        %{"id" => 177, "name" => "Xe ATV & Xe AWD",  },
        %{"id" => 179, "name" => "Xe máy",  },
        %{"id" => 180, "name" => "Golf",  },
        %{"id" => 181, "name" => "Vượt thác",  },
        %{"id" => 19, "name" => "Cắm trại",  },
        %{"id" => 119, "name" => "Hoạt động thể lực",  },
        %{"id" => 120, "name" => "Sống khoẻ",  }
      ]
    },
    %{
      "id" => 122,
      "name" => "Trải nghiệm văn hoá",
      "children" => [
        %{"id" => 25, "name" => "Workshop",  },
        %{"id" => 182, "name" => "Buổi học nấu ăn",  },
        %{"id" => 26, "name" => "Thử trang phục bản xứ",  },
        %{"id" => 183, "name" => "Chụp ảnh",  }
      ]
    },
    %{
      "id" => 38,
      "name" => "Thuê xe tự lái",
    },
    %{
      "id" => 45,
      "name" => "Thuê xe có tài xế riêng",
    },
    %{
      "id" => 52,
      "name" => "Xe máy & Xe đạp",
    },
    %{
      "id" => 102,
      "name" => "Xe sân bay",
    },
    %{
      "id" => 194,
      "name" => "Vé tàu",
      "children" => [%{"id" => 185, "name" => "Vé tàu khác",  }]
    },
    %{
      "id" => 39,
      "name" => "Xe buýt",
    },
    %{
      "id" => 31,
      "name" => "Tàu hoả",
      "children" => []
    },
    %{
      "id" => 151,
      "name" => "Phà",
    },
    %{
      "id" => 65,
      "name" => "WiFi & Thẻ SIM",
    },
    %{
      "id" => 57,
      "name" => "Ẩm thực",
    },
    %{
      "id" => 66,
      "name" => "Dịch vụ du lịch",
      "children" => [
        %{"id" => 67, "name" => "Phòng chờ sân bay & Làn miễn xếp hàng",  },
        %{"id" => 191, "name" => "Visa & Dịch vụ khác",  },
        %{"id" => 68, "name" => "Thuê dụng cụ",  }
      ]
    }
  ]
  
  
  def get_tour(opts \\[]) do
    page = Keyword.get(opts, :page, 1)
    limit = Keyword.get(opts, :limit, 15)
    city_id_string = Enum.map(@city, fn c -> Integer.to_string(c.id) end) |> Enum.join(",")
    url = "https://www.klook.com/v2/usrcsrv/search/country/13/activities?city_id=#{city_id_string}&start=#{page}&size=#{limit}"
    url = URI.encode(url)
    headers = [
      {"accept-language", "vi_VN"},
      {"currency", "VND"},
    ]

    Tools.http_get(url, headers)
    
  end
end

