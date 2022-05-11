defmodule SlackRewriter.Application.UserRegistry do
  @moduledoc """
  UserRegistry
  """
  alias SlackRewriter.Domain.User
  alias SlackRewriter.Repo

  @spec find(String.t()) :: User.t() | nil
  def find(user) do
    User
    |> User.by_id(user)
    |> Repo.one()
  end

  @spec delete(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete(user) do
    Repo.delete(user)
  end

  @spec insert_user!(String.t(), String.t()) :: User.t()
  def insert_user!(id, token) do
    Repo.insert!(
      %User{user_id: id, user_token: token},
      on_conflict: [
        set: [user_token: token, updated_at: DateTime.utc_now()]
      ],
      conflict_target: :user_id
    )
  end
end
