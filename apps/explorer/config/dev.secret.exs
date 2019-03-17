use Mix.Config

# Configure your database
config :explorer, Explorer.Repo,
  database: "explorer_dev",
  hostname: "localhost",
  username: "blockscout",
  password: "blockscout",
  pool_size: 20,
  timeout: 80_000
