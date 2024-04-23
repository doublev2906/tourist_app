defmodule TouristApp.Auth do
  import Plug.Conn
  use Phoenix.Controller
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _) do
    token = Plug.Conn.get_req_header(conn, "authorization") |> IO.inspect()
    TouristApp.Guardian.decode_and_verify(Enum.at(token, 0))
    |> case do
      {:ok, %{"sub" => user_id}} ->
        conn
        |> assign(:user_id, user_id)
      _ ->
        conn
          |> put_resp_header("content-type", "application/json; charset=UTF-8")
          |> send_resp(200, Jason.encode!(%{success: false, message: "Access token is invalid"}))
          |> halt
    end
  end
end