defmodule SlackRewriterWeb.PageController do
  use SlackRewriterWeb, :controller

  alias SlackRewriter.Bridge.Slack

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def app_install(conn, _params) do
    redirect(conn, external: Slack.oauth_redirect())
  end

  # add fallback clause matching for auth denies
end
