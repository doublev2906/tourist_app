defmodule TouristApp.Trip do
  alias TouristApp.{Repo, User, Tools}
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "trips" do
    field :name, :string
    field :list_destinations, {:array, :string}, default: []  
    field :start_at, :string
    field :end_at, :string
    field :destinations_comment, :map, default: %{}
    field :destinations_plan, :map, default: %{}
    belongs_to :user, User

    timestamps()
  end

  def get_trips(%{"user_id" => user_id}), do: Repo.all(from t in __MODULE__, where: t.user_id == ^user_id, order_by: [desc: t.inserted_at])

  def get_trip_by_id(id), do: Repo.get_by(__MODULE__, %{id: id})

  def insert_trip(%{"name" => name, "user_id" => user_id}) do
    data = %{
      name: name,
      user_id: user_id
    }
    struct(__MODULE__, data)
    |> Repo.insert!()
  end

  def update_trip(%{"id" => id, "change" => change} = params) do
    Repo.get_by(__MODULE__, %{id: id})
    |> Ecto.Changeset.change(Tools.to_atom_keys_map(change))
    |> Repo.update!()
  end
end
