use Mix.Config

config :shorty, ecto_repos: [Shorty.Repo]

config :shorty, Shorty.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "shorty_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
