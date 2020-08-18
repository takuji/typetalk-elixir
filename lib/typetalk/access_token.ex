defmodule Typetalk.AccessToken do
  @moduledoc """
  A AccessToken struct and functions.
  """
  import Typetalk.Util

  defstruct access_token: nil, token_type: "Bearer", expires_in: 0, refresh_token: nil

  @type t :: %__MODULE__{access_token: String.t, token_type: String.t, expires_in: non_neg_integer, refresh_token: String.t}

  @doc """
  Refresh the access token.

  ## Example
      {:ok, token} = Typetalk.ClientCredential.access_token(client_id, client_secret)
      {:ok, refreshed_token} = Typetalk.AccessToken.refresh(access_token, client_id, client_secret)

  ## API Doc
  [API Doc](https://developer.nulab-inc.com/docs/typetalk/auth#refresh)
  """
  @spec refresh(__MODULE__, String.t, String.t) :: {:ok, __MODULE__}|{:error, HTTPoison.Response.t}
  def refresh(%__MODULE__{refresh_token: refresh_token}, client_id, client_secret) do
    {:form, [grant_type: "refresh_token", client_id: client_id, client_secret: client_secret, refresh_token: refresh_token]}
    |> get_access_token
  end

  def get_access_token(post_data) when is_tuple(post_data) do
    HTTPoison.post("https://typetalk.com/oauth2/access_token", post_data)
    |> handle_response
    |> response_to_access_token
  end

  defp response_to_access_token({:ok, map}) do
    {:ok, from_map(map)}
  end

  defp response_to_access_token({_, any}) do
    {:error, any}
  end

  defp from_map(%{"access_token" => access_token,
                 "token_type" => token_type,
                 "expires_in" => expires_in,
                 "refresh_token" => refresh_token}) do
    %__MODULE__{access_token: access_token,
                token_type: token_type,
                expires_in: expires_in,
                refresh_token: refresh_token}
  end
end
