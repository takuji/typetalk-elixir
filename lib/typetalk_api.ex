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

  @api_base "https://typetalk.in/api/v1"
  @default_params [grant_type: "client_credentials", scope: "my,topic.read,topi.post"]

  defp get(auth, path, params \\ :empty) do
    case params do
      :empty -> "#{@api_base}/#{path}"
      _ -> "#{@api_base}/#{path}?#{URI.encode_query(params)}"
    end
    |> HTTPoison.get(auth_header(auth))
    |> handle_response
  end

  defp post(auth, path, params \\ []) do
    data = if params == :empty, do: "", else: {:form, params}
    HTTPoison.post("#{@api_base}/#{path}", data, auth_header(auth))
    |> handle_response
  end

  defp put(auth, path, params \\ :empty) do
    data = if params == :empty, do: "", else: "?#{URI.encode_query(params)}"
    "#{@api_base}/#{path}#{data}"
    |> HTTPoison.put("", auth_header(auth))
    |> handle_response
  end

  defp delete(auth, path) do
    "#{@api_base}/#{path}"
    |> HTTPoison.delete(auth_header(auth))
    |> handle_response
  end

  def access_token(auth) do
    params = {:form, Keyword.merge(@default_params, auth)}
    HTTPoison.post("https://typetalk.in/oauth2/access_token", params)
    |> handle_response
  end

  def profile(auth) do
    get(auth, "profile")
  end

  def account_profile(auth, account_name) do
    get(auth, "accounts/profile/#{account_name}")
  end

  def accounts_status(auth, accounts \\ []) do
    q = Enum.join(accounts, ",")
    get(auth, "accounts/status", %{"accountIds" => q})
  end

  def topics(auth) do
    get(auth, "topics")
  end

  def messages(auth) do
    get(auth, "messages")
  end

  def topic_posts(auth, topic_id) do
    get(auth, "topics/#{topic_id}")
  end

  def create_topic_post(auth, topic_id, message, options \\ []) do
    params = options |> Keyword.merge([message: message])
    post(auth, "topics/#{topic_id}", params)
  end

  def topic_members(auth, topic_id) do
    get(auth, "topics/#{topic_id}/members/status")
  end

  def topic_post(auth, topic_id, post_id) do
    get(auth, "topics/#{topic_id}/posts/#{post_id}")
  end

  def update_topic_post(auth, topic_id, post_id, message) do
    put(auth, "topics/#{topic_id}/posts/#{post_id}", %{"message" => message})
  end

  def delete_topic_post(auth, topic_id, post_id) do
    delete(auth, "topics/#{topic_id}/posts/#{post_id}")
  end

  # Like

  def create_like(auth, topic_id, post_id) do
    post(auth, "topics/#{topic_id}/posts/#{post_id}/like")
  end

  def delete_like(auth, topic_id, post_id) do
    delete(auth, "topics/#{topic_id}/posts/#{post_id}/like")    
  end

  # Favorite topic

  def add_to_favorite(auth, topic_id) do
    post(auth, "topics/#{topic_id}/favorite")
  end

  def delete_from_favorite(auth, topic_id) do
    delete(auth, "topics/#{topic_id}/favorite")
  end

  # Direct messages

  def messages_of_account(auth, account_name, options \\ []) do
    data = Keyword.merge([direction: "forward"], options)
    account = URI.encode("@#{account_name}")
    get(auth, "messages/#{account}", data)
  end

  # Notifications

  def notifications(auth) do
    get(auth, "notifications")
  end

  def notifications_status(auth) do
    get(auth, "notifications/status")
  end

  def mark_notifications_as_read(auth) do
    put(auth, "notifications")    
  end

  # Topics

  def mark_topic_as_read(auth, topic_id, post_id \\ nil) do
    params = if post_id == nil, do: [topicId: topic_id], else: [topicId: topic_id, postId: post_id]
    put(auth, "bookmarks", params)
  end

  # Mentions

  def mentions(auth, options \\ :empty) do
    get(auth, "mentions", options)
  end

  def mark_mention_as_read(auth, mention_id) do
    put(auth, "mentions/#{mention_id}")
  end

  # Private functioins

  defp auth_header(auth) do
    %{"Authorization" => "Bearer #{auth["access_token"]}"}
  end

  defp handle_response({:ok, res}) do
    case res.status_code do
      200 -> Poison.decode(res.body)
      _ -> {:error, res}
    end
  end

  defp handle_response({_, err}) do
    {:error, err}
  end
end
