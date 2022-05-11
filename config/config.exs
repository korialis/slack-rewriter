# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :slack_rewriter,
  ecto_repos: [SlackRewriter.Repo]

config :slack_rewriter, :slack,
  slack_oauth_redirect: "oauth_redirect_link",
  slack_api_base: "https://slack.com/api",
  slack_oauth_access: "https://slack.com/api/oauth.v2.access",
  slack_update_message: "https://slack.com/api/chat.update",
  slack_post_ephemeral: "https://slack.com/api/chat.postEphemeral"

config :slack_rewriter, :app,
  app_secret: "secret",
  app_id: "id",
  app_bot_token: "bot_token",
  app_signing_secret: "signing_secret"

# config the cloak.ecto vault
config :slack_rewriter, SlackRewriter.Support.Vault,
  json_library: Jason,
  ciphers: [
    default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: Base.decode64!("cloakkey")}
  ]

# Configures the endpoint
config :slack_rewriter, SlackRewriterWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SlackRewriterWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SlackRewriter.PubSub,
  live_view: [signing_salt: "QDGFa/og"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
