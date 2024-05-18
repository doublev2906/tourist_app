defmodule TouristApp.MomentsUserFavorite do
  use TouristAppWeb, :model

  alias TouristApp.{Repo, Moment, User}
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "moments_user_favorite" do
    
    belongs_to :moment, Moment, type: :binary_id
    belongs_to :user, User, type: :binary_id 

    timestamps()
  end

  def changeset(moment, params \\ %{}) do
    moment
    |> cast(params, [:moment_id, :user_id])
    |> validate_required([:moment_id, :user_id])
  end

  def get_moments_by_user_id(user_id) do
    Repo.all(from m in __MODULE__, where: m.user_id == ^user_id, order_by: [desc: m.inserted_at], select: m.moment_id)
  end

  def insert(params) do
    %__MODULE__{
      user_id: params["user_id"],
      moment_id: params["moment_id"],
    }
    |> Repo.insert()
  end

end