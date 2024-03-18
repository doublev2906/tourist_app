defmodule TouristApp.Api.GeoapifyApi do
  @api_key "b8568cb9afc64fad861a69edbddb2658"
  @base_url "https://api.geoapify.com/v2"

  alias TouristApp.{Tools}

  def test do
    IO.inspect("lala")
    categories = ["tourism.sights","commercial"]
    coordinates = %{
      latitude: 105.84225910105386,
      longitude: 21.032009805676168
    }
    get_place(categories, coordinates, limit: 20, radius: 15000)
  end

  def get_place(categories, coordinates, opts) do
    limit = Keyword.get(opts, :limit, 200)
    radius = Keyword.get(opts, :radius, 15000)
    path = "#{@base_url}/places?"
    new_coordinates = "#{coordinates.latitude},#{coordinates.longitude}"
    url ="#{path}categories=#{Enum.join(categories, ",")}&conditions=named&filter=circle:#{new_coordinates},#{radius}&bias=proximity:#{new_coordinates}&lang=en&limit=#{limit}&apiKey=#{@api_key}"
    
    Tools.http_get(url)
  end
end