defmodule TouristApp.Tools do

  @earth_radius_km 6371000.0

  def schema_to_map(obj) do
    schema = obj.__struct__
    fields = schema.__schema__(:fields)
    Map.take(obj, fields)
  end

  def to_atom_keys_map(%DateTime{} = datetime), do: datetime
  def to_atom_keys_map(%NaiveDateTime{} = datetime), do: datetime
  def to_atom_keys_map(string_map) when is_map(string_map), do: for {k, v} <- string_map, into: %{}, do: { (if is_atom(k), do: k, else: String.to_atom(k)), to_atom_keys_map(v)}
  def to_atom_keys_map(list) when is_list(list), do: Enum.map(list, fn elem -> to_atom_keys_map(elem)  end)
  def to_atom_keys_map(not_is_map), do: not_is_map
  def to_atom_keys_map(string_map, true), do: for {k, v} <- string_map, into: %{}, do: { (if is_atom(k), do: k, else: String.to_atom(k)), v}
  def to_atom_keys_map(string_map, false), do: to_atom_keys_map(string_map)


  def haversine_distance(%{"latitude" => lat1, "longitude" => lon1}, %{"latitude" => lat2, "longitude" => lon2}) do
    d_lat = deg2rad(lat2 - lat1)
    d_lon = deg2rad(lon2 - lon1)

    a = Math.sin(d_lat / 2) * Math.sin(d_lat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(d_lon / 2) * Math.sin(d_lon / 2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    @earth_radius_km * c
  end

  defp deg2rad(degrees) do
    degrees * Math.pi / 180
  end
  
  def http_get(url, headers \\ [], err_msg \\ "Không thể thực hiện GET", timeout \\ 60000, data \\ %{}) do
    # url = if length(Map.keys(data)) > 0, do: "#{url}?#{encode_data(data)}", else: url
    # url = if String.contains?(url, "graph.facebook.com") && !String.contains?(url, "oauth"), do: spider_wrap_url(url), else: url
    # headers = if String.contains?(url, "graph.facebook.com"), do: headers ++ [{"Accept-Encoding", "gzip"}], else: headers
    # handle_http_response(HTTPoison.get(url, headers, [recv_timeout: timeout, hackney: [cookie: ["c_user=10"]]]), url, err_msg)
    IO.inspect(url)
    IO.inspect(headers)
    handle_http_response(HTTPoison.get(url, headers, [recv_timeout: timeout]), url, err_msg)
  end

    def http_post(url, data, headers \\ [], err_msg \\ "Không thể thực hiện POST") do
    opts = [recv_timeout: 45000]
    # opts = if hackney_opts != [], do: opts ++ [hackney: hackney_opts], else: opts
    handle_http_response(HTTPoison.post(url, data, headers, opts), url, err_msg)
  end


  def handle_http_response(response, url, err_msg), do: handle_http_response(response, url, err_msg, 0)
  def handle_http_response(response, url, err_msg, _count, opts \\ []) do
    case response do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body, headers: headers}} ->
        is_gzipped = Enum.any?(headers, fn (kv) ->
          case kv do
            {"Content-Encoding", "gzip"} -> true
            {"Content-Encoding", "x-gzip"} -> true
            _ -> false
          end
        end)

        body = if is_gzipped, do: :zlib.gunzip(body) , else: body

        is_success = cond do
          status_code >= 200 and status_code < 300 -> true
          true -> false
        end

        response =
          case Jason.decode(body) do
            {:ok, response} -> response
            {:error, _}     ->
              if String.contains?(url, "https://graph.facebook.com/") do
                PancakeV2.Rescue.convert_string_error_to_map(body)
              else
                body
              end
          end

        result = %{"success" => is_success, "response" => response, "status_code" => status_code}

        if Keyword.get(opts, :return_headers) do
          Map.put(result, "headers", headers)
        else
          result
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        # IO.inspect response
        # IO.puts "ERROR URL: #{url}"

        %{
          "success" => false,
          "message" => reason || err_msg
        }
    end
  end

  def encode_data(kv, encoder \\ &to_string/1) do
   IO.iodata_to_binary encode_pair("", kv, encoder)
  end


  # covers structs
  defp encode_pair(field, %{__struct__: struct} = map, encoder) when is_atom(struct) do
   [field, ?=|encode_value(map, encoder)]
  end

  # covers maps
  defp encode_pair(parent_field, %{} = map, encoder) do
   encode_kv(map, parent_field, encoder)
  end

  # covers keyword lists
  defp encode_pair(parent_field, list, encoder) when is_list(list) and is_tuple(hd(list)) do
   encode_kv(Enum.uniq_by(list, &elem(&1, 0)), parent_field, encoder)
  end

  # covers non-keyword lists
  defp encode_pair(parent_field, list, encoder) when is_list(list) do
   prune Enum.flat_map list, fn value ->
     [?&, encode_pair(parent_field <> "[]", value, encoder)]
   end
  end

  # covers nil
  defp encode_pair(field, nil, _encoder) do
   [field, ?=]
  end

  # encoder fallback
  defp encode_pair(field, value, encoder) do
   [field, ?=|encode_value(value, encoder)]
  end

    defp encode_kv(kv, parent_field, encoder) do
   prune Enum.flat_map kv, fn
     {_, value} when value in [%{}, []] ->
       []
     {field, value} ->
       field =
         if parent_field == "" do
           encode_key(field)
         else
           parent_field <> "[" <> encode_key(field) <> "]"
         end
       [?&, encode_pair(field, value, encoder)]
   end
  end

  defp encode_key(item) do
   item |> to_string |> URI.encode_www_form
  end

  defp encode_value(item, encoder) do
    item |> encoder.() |> URI.encode_www_form
  end

  defp prune([?&|t]), do: t
  defp prune([]), do: []
end