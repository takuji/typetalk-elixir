defmodule TypeTalk.ClientCredential do  
  @moduledoc """
  Function to get an access token using a client credential.

  You use this module when you are the only user of Typetalk API.
  """

  import TypeTalk.Util

  @default_scope "my,topic.read,topi.post"

  @doc """
  Returns an access token and related information.

  ## Example
      {:ok, auth} = TypeTalk.ClientCredential.access_token("your-client-id",
                                                           "your-client-secret",
                                                           "my,topic.read,topic.post")
  ## API Doc
  [API Doc](https://developer.nulab-inc.com/docs/typetalk/auth#client)
  """
  def access_token(client_id, client_secret, scope \\ @default_scope) do
    params = {:form, [grant_type: "client_credentials", client_id: client_id, client_secret: client_secret, scope: scope]}
    HTTPoison.post("https://typetalk.in/oauth2/access_token", params)
    |> handle_response
  end
end
