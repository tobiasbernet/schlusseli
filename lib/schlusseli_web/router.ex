defmodule SchlusseliWeb.Router do
  use SchlusseliWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    # plug(Schlusseli.Plug.OpenidConnector)
  end

  scope "/", SchlusseliWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api" do
    pipe_through :api

    forward("/", Absinthe.Plug, schema: SchlusseliWeb.Schema)
  end
end
