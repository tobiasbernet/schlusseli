# Schlusseli

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Start schlusseli and keycloak: `./startup.sh`.

Keycloak: Now you can visit [`http://127.0.0.1:8085/auth/`](http://127.0.0.1:8085/auth/) from your browser.

## Keycloak setup

Create 3 clients:

  * `schlusseli-api`: Bearer-only client. The API backend service.
  * `schlusseli-ui`: Confidential client has access to the `schlusseli-api` service.
  * `evil-ui`: Confidential client, has no access to the `schlusseli-api`. 

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
#
