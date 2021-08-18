defmodule Schlusseli.Plug.OpenidConnector do
@moduledoc """
  Plug for verifying authorization on a per request basis, verifies that a token is set in the
  `Authorization` header.

  Problem: OpenIDConnect verifies the token with the public key. No `introspec` is made. We don't know if the token is valid or not.
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
  Verifies the token with OpenIDConnect and adds the claims to the conn.
  """
  def verify_token(token, conn, auth_provider \\ :keycloak) do
    with {:ok, claims} <- OpenIDConnect.verify(auth_provider, token),
    true <- verify_audience(claims, get_provider_conf(:verify_token_audience)) do
      conn
      |> Absinthe.Plug.put_options(context: %{claims: normalize_claims(claims)})
    else
      _ -> auth_error(conn)
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

  defp normalize_claims(claims) do
    for {key, val} <- claims, into: %{}, do: {String.to_atom(key), val}
  end
end
