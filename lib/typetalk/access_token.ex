defmodule Typetalk.AccessToken do
  @moduledoc """
  """
  import Typetalk.Util

  defstruct access_token: nil, token_type: "Bearer", expires_in: 0, refresh_token: nil

  @type t :: %__MODULE__{access_token: String.t, token_type: String.t, expires_in: non_neg_integer, refresh_token: String.t}

  def refresh(client_id, client_secret, %__MODULE__{refresh_token: refresh_token}) do
    {:form, [grant_type: "refresh_token", client_id: client_id, client_secret: client_secret, refresh_token: refresh_token]}
    |> get_access_token
  end

  def get_access_token(params) do
    HTTPoison.post("https://typetalk.in/oauth2/access_token", params)
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
