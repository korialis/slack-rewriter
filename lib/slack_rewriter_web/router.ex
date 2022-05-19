defmodule SlackRewriterWeb.Router do
  use SlackRewriterWeb, :router

  alias Plug.Conn

  @slack_signing_secret Application.compile_env!(:slack_rewriter, :app)[:app_signing_secret]

  defp slack_verifier(conn, _opts) do
    body_string = conn.private[:raw_body]

    slack_ts = hd(Conn.get_req_header(conn, "x-slack-request-timestamp"))

    slack_signature = hd(Conn.get_req_header(conn, "x-slack-signature"))
    [version, signature] = String.split(slack_signature, "=")

    hash =
      Base.encode16(
        :crypto.mac(
          :hmac,
          :sha256,
          @slack_signing_secret,
          "#{version}:#{slack_ts}:#{body_string}"
        )
      )

    if hash == String.upcase(signature) do
      conn
    else
      conn |> send_resp(401, "Slack signature verification failed") |> halt()
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug :slack_verifier
  end

  pipeline :api_install do
    plug :accepts, ["json"]
  end

  scope "/", SlackRewriterWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/app-install/", PageController, :app_install
  end

  # scope for core api endpoints.
  scope "/api", SlackRewriterWeb do
    pipe_through :api

    post "/events", EventApiController, :event_handler
  end

  # scope for api install endpoint
  scope "/api", SlackRewriterWeb do
    pipe_through :api_install

    get "/app-install/code", EventApiController, :app_install_code
  end
end
