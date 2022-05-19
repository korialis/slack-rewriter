import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :slack_rewriter, SlackRewriter.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  database: "slack_rewriter_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :slack_rewriter, SlackRewriterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dsK4YaB38snlqaAbYdEA6Ywa+BsZlXgzr7qfF3XuJ/AM+BWJV2V4zILpgzRQ5Exv",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
