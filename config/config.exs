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

# OpenID provider config
config :schlusseli, :openid_connect_providers,
  keycloak: [
    discovery_document_uri: "http://127.0.0.1:8084/auth/realms/Schlusseli/.well-known/openid-configuration",
    client_id: "app-api",
    client_secret: "9daec6ad-c6ac-4cde-b955-dc846c2cfbbb",
    redirect_uri: "",
    response_type: "code",
    scope: "api-service",
    verify_token_audience: true
  ]



# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
