defmodule Schlusseli.Plug.KeycloakIntorspect do
@moduledoc """
  Plug to verify token via keycloak's introspection endpoint.


  The verification by the Keycloak introspect endpoint ensures that the token becomes invalid after a revoke.
  """

  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc """
  Fetches the `Authorization` header, and verifies the token if present. If a
  valid token is passed, the decoded `%Joken.Token{}` is added as `:token`
  to the `conn` assigns.
  """
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _) do
    conn
      |> get_req_header("authorization")
      |> fetch_token()
      |> verify_token(conn)
  end

  def fetch_token([token]) when is_binary(token) do
    token
    |> String.split(" ")
    |> List.last()
  end

  def fetch_token(_), do: nil

  @doc """
  Verifies the token using the introspect endpoint.
  """
  def verify_token(token, conn) do
    with {:ok, claims} <- token_introspect(token),
    true <- verify_audience(claims, get_provider_conf(:verify_token_audience)) do
      conn
      |> assign(:claims, claims)
    else
      _ -> auth_error(conn)
    end
  end

  @doc """
  Introspection of the given token (https://datatracker.ietf.org/doc/html/rfc7662)[OAuth2 token introspection].
  """
  def token_introspect(token) do
    uri = get_provider_conf(:introspect_uri)

    form_body = [
      client_id: get_provider_conf(:client_id),
      client_secret: get_provider_conf(:client_secret),
      token: token
    ]

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    with {:ok, %HTTPoison.Response{status_code: status_code} = resp} when status_code in 200..299 <-
           http_client().post(uri, {:form, form_body}, headers),
         {:ok, json} <- Jason.decode(resp.body),
         {:ok, json} <- assert_json(json) do
      {:ok, json}
    else
      {:ok, resp} -> {:error, :introspect_tokens, resp}
      {:error, reason} -> {:error, :introspect_tokens, reason}
    end
  end

  @doc """
  Checks the audience if the `verify token audience` is `true`.
  """
  def verify_audience(%{"aud" => aud}, true) when is_binary(aud) do
    aud == get_provider_conf(:client_id)
  end

  def verify_audience(_, true), do: false

  def verify_audience(_, _), do: true

  defp get_provider_conf(key, auth_provider \\ :keycloak) do
    Application.get_env(:schlusseli, :openid_connect_providers)
    |> get_in([auth_provider, key])
  end

  defp auth_error(conn) do
    conn
        |> put_resp_content_type("application/vnd.api+json")
        |> send_resp(401, Poison.encode!(%{error: :not_authorized}))
        |> halt()
  end

  defp assert_json(%{"error" => reason}), do: {:error, reason}
  defp assert_json(json), do: {:ok, json}

  defp http_client do
    Application.get_env(:schlusseli, :http_client, HTTPoison)
  end
end
