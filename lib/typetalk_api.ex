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

  defp post(auth, path, params \\ :empty) do
    data = cond do
      is_binary(params) -> params
      is_list(params) ->{:form, params}
      is_map(params) -> {:form, Enum.into(params, [])}
      params == :empty -> ""
    end
    header = Map.merge(auth_header(auth), %{"Content-Type" => "application/x-www-form-urlencoded"})
    # data = if params == :empty, do: "", else: {:form, params}
    HTTPoison.post("#{@api_base}/#{path}", data, header)
    |> handle_response
  end

  defp put(auth, path, params \\ :empty) do
    data = if params == :empty, do: "", else: "?#{URI.encode_query(params)}"
    "#{@api_base}/#{path}#{data}"
    |> HTTPoison.put("", auth_header(auth))
    |> handle_response
  end

  defp delete(auth, path, params \\ :empty) do
    data = if params == :empty, do: "", else: "?#{URI.encode_query(params)}"
    "#{@api_base}/#{path}#{data}"
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

  def post_direct_message(auth, account_name, message, options) do
    data = options |> Keyword.merge([message: message])
    post(auth, "messages/@#{account_name}", data)
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

  def create_topic(auth, name, space_key, options \\ %{}) do
    params = Enum.into(options, [name: name, spaceKey: space_key])
    post(auth, "topics", params)
  end

  @update_topic_options MapSet.new([:description])

  def update_topic(auth, topic_id, name, options \\ []) do
    data = options
         |> Enum.filter(fn({k,v}) -> MapSet.member?(@update_topic_options, k) end)
         |> Keyword.merge([name: name])
    put(auth, "topics/#{topic_id}", data)
  end

  def delete_topic(auth, topic_id) do
    delete(auth, "topics/#{topic_id}")
  end

  def topic_details(auth, topic_id) do
    get(auth, "topics/#{topic_id}/details")
  end

  # No test
  def update_topic_members(auth, topic_id, params) do
    # [:addAccountIds, :addGroupIds, :invitationEmails, :invitationRoles, :removeAccountIds, :cancelSpaceInvitation, :removeGroupIds]
    post(auth, "topics/#{topic_id}/members/update", params)
  end

  # Mentions

  def mentions(auth, options \\ :empty) do
    get(auth, "mentions", options)
  end

  def mark_mention_as_read(auth, mention_id) do
    put(auth, "mentions/#{mention_id}")
  end

  # Spaces

  def spaces(auth) do
    get(auth, "spaces")
  end

  def space_members(auth, space_key) do
    get(auth, "spaces/#{space_key}/members")
  end

  # Search accounts

  def search_friends(auth, q, options \\ []) do
    params = %{
      q: q,
      offset: Keyword.get(options, :offset, 0),
      count: Keyword.get(options, :count, 30)
    }
    get(auth, "search/friends", params)
  end

  def search_account(auth, name_or_email) do
    get(auth, "search/accounts", [nameOrEmailAddress: name_or_email])
  end

  # Talks

  def talks(auth, topic_id) do
    get(auth, "topics/#{topic_id}/talks")
  end

  def create_talk(auth, topic_id, name, post_ids) do
    data = Enum.zip(post_ids, 0..(length(post_ids) - 1))
         |> Enum.reduce(%{"talkName" => name}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(auth, "topics/#{topic_id}/talks", data)
  end

  def talk_posts(auth, topic_id, talk_id) do
    get(auth, "topics/#{topic_id}/talks/#{talk_id}/posts")
  end

  def update_talk(auth, topic_id, talk_id, name) do
    put(auth, "topics/#{topic_id}/talks/#{talk_id}", talkName: name)
  end

  def delete_talk(auth, topic_id, talk_id) do
    delete(auth, "topics/#{topic_id}/talks/#{talk_id}")
  end

  def add_posts_to_talk(auth, topic_id, talk_id, post_ids) do
    data = Enum.zip(post_ids, 0..(length(post_ids) - 1))
         |> Enum.reduce(%{}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(auth, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
  end

  def delete_posts_from_talk(auth, topic_id, talk_id, post_ids) do
    data = [postIds: Enum.join(post_ids, ",")]
    delete(auth, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
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
