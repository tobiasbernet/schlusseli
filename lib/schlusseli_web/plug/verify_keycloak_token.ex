defmodule Schlusseli.Plug.VerifyKeycloakToken do
  @moduledoc """
  Plug for verifying authorization on a per request basis, verifies that a token is set in the
  `Authorization` header.
  """
  use Joken.Config

  import Plug.Conn

  @regex ~r/^Bearer:?\s+(.+)/i

  @doc false
  def init(opts), do: opts

  @doc """
  Fetches the `Authorization` header, and verifies the token if present. If a
  valid token is passed, the decoded `%Joken.Token{}` is added as `:token`
  to the `conn` assigns.
  """
  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _) do
    token = conn
      |> get_req_header("authorization")
      |> fetch_token()

    token
    |> fetch_jwk()
    |> JOSE.JWT.verify_strict(["RS256"], token)
    |> verify_token(conn)
  end

  # 1 hour
  def token_config(), do: default_claims(default_exp: 60 * 60)

  def verify_token({true, %{fields: claims}, _jwt}, conn) do
    conn
    |> assign(:claims, claims)
  end

  def verify_token(_, conn) do
    conn
        |> put_resp_content_type("application/vnd.api+json")
        |> send_resp(401, Poison.encode!(%{error: :not_authorized}))
        |> halt()
  end

  @doc """
  Fetches the token from the `Authorization` headers array, attempting
  to match the token in the format `Bearer <token>`.
  ### Example
      iex> fetch_token([])
      nil
      iex> fetch_token(["abc123"])
      nil
      iex> fetch_token(["Bearer abc123"])
      "abc123"
  """
  @spec fetch_token([String.t()] | []) :: String.t() | nil
  def fetch_token([]), do: nil

  def fetch_token([token | tail]) do
    case Regex.run(@regex, token) do
      [_, token] -> String.trim(token)
      nil -> fetch_token(tail)
    end
  end

  @doc """
  Returns Keycloak's `jwk` key.
  ### Example
      iex> %JOSE.JWK{} = jwk()
      %JOSE.JWK{                                                                                                                                                                                                                                      fields: %{                                                                                                                                                                                                                                      "alg" => "RS256",                                                                                                                                                                                                                             "kid" => "G-v94blcdBuETZaUlzI7DsjpPCjuIZ-nyOemcj2qRFQ",                                                                                                                                                                                       "use" => "sig",
          "x5c" => ["MIICozCCAYsCBgF7LxaaDzANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApTY2hsdXNzZWxpMB4XDTIxMDgxMDA4MDE1NVoXDTMxMDgxMDA4MDMzNVowFTETMBEGA1UEAwwKU2NobHVzc2VsaTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL4+qOf2WWrkHvtxffhQpg8XsnN2aYIfB052B5Aiz3+vY9Xlqocu0OG+3SdaHjZdNnrvE0rXS1PKU6osrjF3bOu86Ypmb7NBCWMFUC2GfGwrRfeW02Pk4JTBVM4BCaI2AAjxyvGDK/kB+RkxKmSC7m8CKet3a90Du/PR4q/BGo2s5V2c6gMgjJ/wyn9WS5voTGJYEL9SKQJy9jtMr80bVOqLX26WDxl0e5RZu0uINvEefLwb6+13bXrSu8iqYEsPLF4MFq2hG5Mvzanj6Z6AWqSojWY1Ivw7aIAkXQqyKWk6Gx57JsOt5FXzg0+6BMo3v3cvROsQLzjwLm7y7KIlqrcCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAd236BoMR25hh0E9usvgeMkF1wF7SsBHB/6gRtc5ar3IHaKh7l0wM9kYTdy1feOhkMz3mep9ub2nllH8+FwycbMd97Fi+c/rB7xZKwJLHO09/Vol97yKIt8m6XqRtAu9z5QqCNbf9icoEUT1iz7XHC/7l3P3BtTgEJSN1LHvpxdwsO3ZjGjjg7M2nMdcIuQe2VIhmIVr4p34D7okVsmgR4Zfnd/BBPklhDMSLIm9TySRgqrInpFKATQoovT5vKWBu1kXyLQJigcOYpMlYLNr4+jirmWJ2LjbIfqukIyipdMpVKD9ROdkfHNKepjrVOeXE8nieVb3+ATPq7B9ApNIQBQ=="],
          "x5t" => "ZnZC1CJMbVj3M3fVuceNDvxHxZk",
          "x5t#S256" => "NJeRma9umkFlGsWVGTFlIRfLOXSe6Q2_Q1mQXWJm-zU"
        },
        keys: :undefined,
        kty: {:jose_jwk_kty_rsa,
        {:RSAPublicKey,
          24016176637345843912297847065333074042040328525957352171941618076767399123581490536251111369279263273355475774951692577012151727042995491450228653838064260739889739362738519354563118725637655920274182703692391694674320039439268400600435007903871893963656708486029407985231860261509282130192833050708421243038826417774558828703572260610271247378602778351477405493274940349909840450221792816928360463815021744198580113239873033338980220636934698462624103423040158732636030801317023545335571021478456728465806351491236443128493343033833764597311682831027147636237937196067935887696449069861887784966769490685911428868791,
          65537}}
      }
  """
  @spec fetch_jwk(String.t()) :: JOSE.JWK.t()
  def fetch_jwk(_token) do
    %{
      "alg" => "RS256",
      "e" => "AQAB",
      "kid" => "G-v94blcdBuETZaUlzI7DsjpPCjuIZ-nyOemcj2qRFQ",
      "kty" => "RSA",
      "n" => "vj6o5_ZZauQe-3F9-FCmDxeyc3Zpgh8HTnYHkCLPf69j1eWqhy7Q4b7dJ1oeNl02eu8TStdLU8pTqiyuMXds67zpimZvs0EJYwVQLYZ8bCtF95bTY-TglMFUzgEJojYACPHK8YMr-QH5GTEqZILubwIp63dr3QO789Hir8EajazlXZzqAyCMn_DKf1ZLm-hMYlgQv1IpAnL2O0yvzRtU6otfbpYPGXR7lFm7S4g28R58vBvr7XdtetK7yKpgSw8sXgwWraEbky_NqePpnoBapKiNZjUi_DtogCRdCrIpaTobHnsmw63kVfODT7oEyje_dy9E6xAvOPAubvLsoiWqtw",
      "use" => "sig",
      "x5c" => ["MIICozCCAYsCBgF7LxaaDzANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDDApTY2hsdXNzZWxpMB4XDTIxMDgxMDA4MDE1NVoXDTMxMDgxMDA4MDMzNVowFTETMBEGA1UEAwwKU2NobHVzc2VsaTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL4+qOf2WWrkHvtxffhQpg8XsnN2aYIfB052B5Aiz3+vY9Xlqocu0OG+3SdaHjZdNnrvE0rXS1PKU6osrjF3bOu86Ypmb7NBCWMFUC2GfGwrRfeW02Pk4JTBVM4BCaI2AAjxyvGDK/kB+RkxKmSC7m8CKet3a90Du/PR4q/BGo2s5V2c6gMgjJ/wyn9WS5voTGJYEL9SKQJy9jtMr80bVOqLX26WDxl0e5RZu0uINvEefLwb6+13bXrSu8iqYEsPLF4MFq2hG5Mvzanj6Z6AWqSojWY1Ivw7aIAkXQqyKWk6Gx57JsOt5FXzg0+6BMo3v3cvROsQLzjwLm7y7KIlqrcCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEAd236BoMR25hh0E9usvgeMkF1wF7SsBHB/6gRtc5ar3IHaKh7l0wM9kYTdy1feOhkMz3mep9ub2nllH8+FwycbMd97Fi+c/rB7xZKwJLHO09/Vol97yKIt8m6XqRtAu9z5QqCNbf9icoEUT1iz7XHC/7l3P3BtTgEJSN1LHvpxdwsO3ZjGjjg7M2nMdcIuQe2VIhmIVr4p34D7okVsmgR4Zfnd/BBPklhDMSLIm9TySRgqrInpFKATQoovT5vKWBu1kXyLQJigcOYpMlYLNr4+jirmWJ2LjbIfqukIyipdMpVKD9ROdkfHNKepjrVOeXE8nieVb3+ATPq7B9ApNIQBQ=="],
      "x5t" => "ZnZC1CJMbVj3M3fVuceNDvxHxZk",
      "x5t#S256" => "NJeRma9umkFlGsWVGTFlIRfLOXSe6Q2_Q1mQXWJm-zU"
    }
    |> JOSE.JWK.from()
  end
end
