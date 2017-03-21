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
    HTTPoison.get("https://typetalk.in/api/v1/profile", auth_header(token))
    |> handle_response    
  end

  def account_profile(token, account_name) do
    HTTPoison.get("https://typetalk.in/api/v1/accounts/profile/#{account_name}", auth_header(token))
    |> handle_response        
  end

  def accounts_status(token, accounts \\ []) do
    q = Enum.zip([accounts, 0..(length(accounts)-1)])
        |> Enum.reduce(%{}, fn ({account, idx}, acc) -> Map.put(acc, "accountIds[#{idx}]", account) end)
        |> URI.encode_query()
    HTTPoison.get("https://typetalk.in/api/v1/accounts/status", auth_header(token))
    |> handle_response        
  end

  def topics(token) do
    HTTPoison.get("https://typetalk.in/api/v1/topics", auth_header(token))
    |> handle_response        
  end

  def messages(token) do
    HTTPoison.get("https://typetalk.in/api/v1/messages", auth_header(token))
    |> handle_response        
  end

  def topic_messages(auth, topic_id) do
    IO.inspect "https://typetalk.in/api/v1/topics/#{topic_id}"
    HTTPoison.get("https://typetalk.in/api/v1/topics/#{topic_id}", auth_header(auth))
    |> handle_response        
  end

  def topic_members(token, topic_id) do
    HTTPoison.get("https://typetalk.in/api/v1/topics/#{topic_id}/members/status", auth_header(token))
    |> handle_response
  end

  # Private functioins

  defp auth_header(auth) do
    %{"Authorization" => "Bearer #{auth["access_token"]}"}
  end

  defp handle_response({:ok, res}) do
    Poison.decode(res.body)
  end

  defp handle_response({_, err}) do
    {:error, err}
  end
end
