defmodule SlackRewriter.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :user_id, :string, primary_key: true
      add :user_token, :binary

      timestamps(type: :utc_datetime_usec)
    end
  end
end
