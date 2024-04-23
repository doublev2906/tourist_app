defmodule TouristApp.User do
  use TouristAppWeb, :model
  import TouristApp.{Repo}

  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :name,                :string
    field :email,               :string
    field :password_hash,       :string
    field :phone_number,        :string

    timestamps()
  end

  defp format_user(user) do
    %{
      id: user.id, 
      name: user.name,
      email: user.email,
      phone_number: user.phone_number,
    }
  end

  def create_user(%{"name" => name, "email" => email, "password" => password, "phone_number" => phone_number}) do
    cond do
      TouristApp.Repo.get_by(__MODULE__, %{email: email}) ->
        {:error, "Email đã tồn tại."}
      true ->
        %__MODULE__{
          name: name,
          email: email,
          password_hash: password,
          phone_number: phone_number,
        } 
        |> TouristApp.Repo.insert!()
        |> format_user()
    end
  end

  def create_user(_), do: {:error, "Thiếu thông tin bắt buộc."}

  def verify_user(%{"email" => email, "password" => password}) do
    case TouristApp.Repo.get_by(__MODULE__, %{email: email, password_hash: password}) do
      nil -> {:error, "Thông tin tài khoản không hợp lệ."}
      user -> {:ok, format_user(user)}
    end
  end

  def verify_user(%{"phone_number" => phone_number, "password" => password}) do
    case TouristApp.Repo.get_by(__MODULE__, %{phone_number: phone_number, password_hash: password}) do
      nil -> {:error, "Thông tin tài khoản không hợp lệ."}
      user -> {:ok, format_user(user)}
    end
  end

  def verify_user(_), do: {:error, "Tham số không hợp lệ"}

  def create_token(user) do
    {:ok, access_token, access_claims} = TouristApp.Guardian.encode_and_sign(user, %{}, [token_type: "access", ttl: {60, :days}])
    {:ok, refresh_token, _} = TouristApp.Guardian.encode_and_sign(user, %{access_token: access_token}, [token_type: "refresh", ttl: {90, :days}])

    %{access_token: access_token, refresh_token: refresh_token, expired_time: access_claims["exp"]}
  end
end