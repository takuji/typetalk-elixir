defmodule TypeTalk.Auth do
  @moduledoc """
  Functions for authentication.
  """

  import TypeTalk.Util

  @default_params [grant_type: "client_credentials", scope: "my,topic.read,topi.post"]

  @doc """
  Returns an access token and related information.

  ## Example
      {:ok, auth} = TypeTalk.access_token(client_id: "xxxxxxxxxxxxxxxx",
                                          client_secret: "************************",
                                          scope: "my,topic.read,topic.post")
  ## API Doc
  [https://developer.nulab-inc.com/docs/typetalk/auth#client](https://developer.nulab-inc.com/docs/typetalk/auth#client)
  """
  def access_token(auth) do
    params = {:form, Keyword.merge(@default_params, auth)}
    HTTPoison.post("https://typetalk.in/oauth2/access_token", params)
    |> handle_response
  end
end