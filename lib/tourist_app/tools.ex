defmodule TouristApp.Tools do
  
  def http_get(url, err_msg \\ "Không thể thực hiện GET", timeout \\ 10000, headers \\ [], data \\ %{}) do
    # url = if length(Map.keys(data)) > 0, do: "#{url}?#{encode_data(data)}", else: url
    # url = if String.contains?(url, "graph.facebook.com") && !String.contains?(url, "oauth"), do: spider_wrap_url(url), else: url
    # headers = if String.contains?(url, "graph.facebook.com"), do: headers ++ [{"Accept-Encoding", "gzip"}], else: headers
    # handle_http_response(HTTPoison.get(url, headers, [recv_timeout: timeout, hackney: [cookie: ["c_user=10"]]]), url, err_msg)
    handle_http_response(HTTPoison.get(url, headers, [recv_timeout: timeout]), url, err_msg)
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
        # if count < 10 do
        #   :timer.sleep(10000)
        #   handle_http_response(response, url, err_msg, count + 1)
        # else
        #   %{
        #     "success" => false,
        #     "message" => reason || err_msg
        #   }
        # end
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