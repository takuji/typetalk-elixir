defmodule Typetalk.AuthorizationCode do  
  @moduledoc """
  Function to get an access token using an authorization code.

  You use this module when you offer a web service to other people.
  """

  import Typetalk.Util

  @default_scope "my,topic.read,topi.post"

  @doc """
  Returns a URL for the authorization

  ## API Doc
  [API Doc](https://developer.nulab-inc.com/docs/typetalk/auth#code)
  """
  @spec authorization_url(String.t, String.t, String.t) :: String.t
  def authorization_url(client_id, redirect_url, scope \\ @default_scope) do
    q = URI.encode_query(client_id: client_id, redirect_url: redirect_url, scope: scope, response_type: "code")
    "https://typetalk.in/oauth2/authorize?#{q}"
  end

  @doc """
  Returns an access token and related information.

  ## Example
      {:ok, auth} = Typetalk.AuthorizationCode.access_token("your-client-id",
                                                            "your-client-secret",
                                                            "https://example.com/oauth_callback",
                                                            "code-returned-by-server")
  ## API Doc
  [API Doc](https://developer.nulab-inc.com/docs/typetalk/auth#code)
  """
  @spec access_token(String.t, String.t, String.t, String.t) :: {:ok, Typetalk.AccessToken.t} | {:error, HTTPoison.Response}
  def access_token(client_id, client_secret, redirect_uri, code) do
    params = {:form, [grant_type: "authorization_code",
                      client_id: client_id,
                      client_secret: client_secret,
                      redirect_uri: redirect_uri,
                      code: code]}
    HTTPoison.post("https://typetalk.in/oauth2/access_token", params)
    |> handle_response
  end
end
