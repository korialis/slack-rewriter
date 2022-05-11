defmodule SlackRewriter.Domain.User do
  @moduledoc """
  User entity
  """
  use Ecto.Schema

  import Ecto.Query

  alias SlackRewriter.Support.EncryptedBinary

  @type t :: %__MODULE__{
          user_id: String.t(),
          user_token: String.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:user_id, :string, []}

  # the user table
  schema "users" do
    field :user_token, EncryptedBinary

    timestamps(type: :utc_datetime)
  end

  @spec by_id(Ecto.Queryable.t(), String.t()) :: Ecto.Queryable.t()
  def by_id(query, id) do
    from(user in query, where: user.user_id == ^id)
  end
end
