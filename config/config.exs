# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :schlusseli,
  ecto_repos: [Schlusseli.Repo]

# Configures the endpoint
config :schlusseli, SchlusseliWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CFJEBkACAvcVmkiKJOa5KodOvjUj9Fg/DReCsSVTdbGlUyCuTDaT5YFmvC8PI1LN",
  render_errors: [view: SchlusseliWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Schlusseli.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


config :keycloak,
  realm: "heidi",
  site: "http://127.0.0.1:8080",
  client_id: "heidi-api",
  client_secret: ""

config :keycloak, Schlusseli.Plug.VerifyToken,
  hmac: "0617b135-6bba-4af0-96a7-5e34b7a1aead"
  #public_key: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhGXASBTDByDsd2BfN1oBLNHveUlHIDonEhhK//lnvKn1GTFhbuId0szZQG4Eenk5laZqcBvbW4WjNuNKV6FtZjQLPUIaJbYMO2g/R4eKsnaQVK8ynHewcbikgB/JhSmw9WknyISmtC+pgSksnilHM2os0V6O5shxCk3ZFRvA6X14PdeQ5ugNilfe2oIhAkO0W+iJgqTIp7EGqYy/wd4M/7QbaoB+wKU1fWjWz+046zZnlAct4KgDi5MlITkuIqbjVOqC4cI+rZk4W459ETJeENowgegx0PXPvTTV1wX63Z8kKElcQewLfp6nA9nR1a9B0SX/6xvwNMXKzVWzjiLZswIDAQAB"


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
