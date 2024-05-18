defmodule TouristApp.MomentComment do

  use TouristAppWeb, :model

  alias TouristApp.{Repo, Tools, User}

  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "moment_comments" do
    field :user_id, :binary_id
    field :moment_id, :binary_id
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(moment_comment, attrs) do
    moment_comment
    |> cast(attrs, [:user_id, :moment_id, :content])
    |> validate_required([:user_id, :moment_id, :content])
  end

  def get_data(params) do
    moment_id = params["moment_id"]
    user_id = params["user_id"]
    offset = params["offset"] || 0
    limit = params["limit"] || 10

    query = from(
      m in __MODULE__,
      join: u in User,
      on: m.user_id == u.id,
      where: m.moment_id == ^moment_id,
      order_by: [desc: m.inserted_at],
      limit: ^limit,
      offset: ^offset,
      select: %{
        id: m.id,
        content: m.content,
        inserted_at: m.inserted_at,
        user: %{
          id: u.id,
          name: u.name          
        }
      }
    )

    query = if user_id do
      from(m in query, where: m.user_id == ^user_id)
    else
      query
    end

    Repo.all(query)
    |> IO.inspect()
  end

  def insert(params) do
    %__MODULE__{
      user_id: params["user_id"],
      moment_id: params["moment_id"],
      content: params["content"]
    }
    |> Repo.insert()
    
  end
end
