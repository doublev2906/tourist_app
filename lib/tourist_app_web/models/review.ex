defmodule TouristApp.Review do
  alias TouristApp.{Repo, User, Review}
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reviews" do
    field :place_id, :string
    field :content, :string
    field :images, {:array, :string}
    field :rating, :float
    field :type, :string
    field :extra_info, :map, default: %{}

    belongs_to :user, User

    timestamps()
  end

  def changeset(review, params \\ %{}) do
    review
    |> cast(params, [:place_id, :user_id, :content, :images, :rating, :type, :extra_info])
    |> validate_required([])
  end

  def get_reviews_by_place_id(place_id, type, opts \\ []) do
    offset = opts[:offset] || 0
    limit = opts[:limit] || 8
    from(
      r in __MODULE__,
      join: u in User, on: u.id == r.user_id,
      where: r.place_id == ^place_id and r.type == ^type,
      order_by: [desc: r.rating],
      offset: ^offset,
      limit: ^limit,
      select: %{
        id: r.id,
        content: r.content, 
        images: r.images, 
        rating: r.rating, 
        inserted_at: r.inserted_at, 
        from: %{
          id: u.id,
          name: u.name
        }
      }
    ) 
    |> Repo.all
  end

  def insert(review) do
    struct(Review, review)
    |> Repo.insert()
  end
end