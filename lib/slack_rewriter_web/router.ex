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
    plug :fetch_live_flash
    plug :put_root_layout, {SlackRewriterWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    # add plug to verify app authenticity (either by token or signed secret)
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

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SlackRewriterWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
