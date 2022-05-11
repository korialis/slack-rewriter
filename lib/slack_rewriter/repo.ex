defmodule SlackRewriter.Repo do
  use Ecto.Repo,
    otp_app: :slack_rewriter,
    adapter: Ecto.Adapters.Postgres
end
