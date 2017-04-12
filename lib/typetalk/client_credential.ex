defmodule Typetalk.ClientCredential do  
  @moduledoc """
  Function to get an access token using a client credential.

  You use this module when you are the only user of Typetalk API.
  """

  @type auth :: Typetalk.AccessToken.t

  import Typetalk.Util

  @default_scope "my,topic.read,topi.post"

  @doc """
  Returns an access token and related information.

  ## Example
      {:ok, auth} = Typetalk.ClientCredential.access_token("your-client-id",
                                                           "your-client-secret",
                                                           "my,topic.read,topic.post")
  ## API Doc
  [API Doc](https://developer.nulab-inc.com/docs/typetalk/auth#client)
  """
  @spec access_token(String.t, String.t, String.t) :: {:ok, auth}|{:error, HTTPoison.Response.t}
  def access_token(client_id, client_secret, scope \\ @default_scope) do
    {:form, [grant_type: "client_credentials", client_id: client_id, client_secret: client_secret, scope: scope]}
    |> Typetalk.AccessToken.get_access_token
  end
end
