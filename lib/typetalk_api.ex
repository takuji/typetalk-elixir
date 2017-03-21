defmodule TypeTalk do
  @moduledoc """
  Documentation for TypeTalk.
  """

  @doc """
  Hello world.

  ## Examples

      iex> TypeTalk.hello
      :world

  """
  def hello do
    :world
  end

  @default_params [grant_type: "client_credentials", scope: "my"]

  def access_token(auth) do
    params = {:form, Keyword.merge(@default_params, auth)}
    HTTPoison.post("https://typetalk.in/oauth2/access_token", params)
    |> handle_response
  end

  def profile(token) do
    HTTPoison.get("https://typetalk.in/api/v1/profile", %{"Authorization" => "Bearer #{token["access_token"]}"})
    |> handle_response    
  end

  defp handle_response({:ok, res}) do
    Poison.decode(res.body)
  end

  defp handle_response({_, err}) do
    {:error, err}
  end
end
