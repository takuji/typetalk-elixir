defmodule TypeTalk do
  import TypeTalk.Util
  
  @moduledoc """
  Documentation for TypeTalk.
  """

  @api_base "https://typetalk.in/api/v1"

  defp get(auth, path, params \\ :empty) do
    case params do
      :empty -> "#{@api_base}/#{path}"
      _ -> "#{@api_base}/#{path}?#{URI.encode_query(params)}"
    end
    |> HTTPoison.get(auth_header(auth))
    |> handle_response
  end

  defp post(auth, path) do
    header = Map.merge(auth_header(auth), %{"Content-Type" => "application/x-www-form-urlencoded"})
    HTTPoison.post("#{@api_base}/#{path}", "", header)
    |> handle_response
  end

  defp post(auth, path, params) when is_binary(params) do
    header = Map.merge(auth_header(auth), %{"Content-Type" => "application/x-www-form-urlencoded"})
    HTTPoison.post("#{@api_base}/#{path}", params, header)
    |> handle_response
  end

  defp post(auth, path, params) when is_list(params) do
    HTTPoison.post("#{@api_base}/#{path}", {:form, params}, auth_header(auth))
    |> handle_response
  end

  defp post(auth, path, params) when is_map(params) do
    HTTPoison.post("#{@api_base}/#{path}", {:form, Enum.into(params, [])}, auth_header(auth))
    |> handle_response
  end

  defp post_file(auth, path, file) when is_binary(file) do
    data = {:multipart, [{:file, file}]}
    HTTPoison.post("#{@api_base}/#{path}", data, auth_header(auth))
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

  @doc """
  Returns the profile of the caller.
  ## API Doc
  [https://developer.nulab-inc.com/docs/typetalk/api/1/get-profile](https://developer.nulab-inc.com/docs/typetalk/api/1/get-profile)
  """
  def get_profile(auth) do
    get(auth, "profile")
  end

  @doc """
  Returns the profile of the given account name.
  """
  def get_friend_profile(auth, account_name) do
    get(auth, "accounts/profile/#{account_name}")
  end

  @doc """
  Returns the online status of accounts.
  """
  def get_online_status(auth, account_ids) do
    q = Enum.join(account_ids, ",")
    get(auth, "accounts/status", %{"accountIds" => q})
  end

  @doc """
  Returns the topics.
  """
  def get_topics(auth) do
    get(auth, "topics")
  end

  @doc """
  Returns direct message topics.
  """
  def get_dm_topics(auth) do
    get(auth, "messages")
  end

  @doc """
  Returns messages of a topic.
  """
  def get_messages(auth, topic_id) do
    get(auth, "topics/#{topic_id}")
  end

  @doc """
  Post a message to a topic.
  """
  def post_message(auth, topic_id, message, options \\ []) do
    params = options |> Keyword.merge([message: message])
    post(auth, "topics/#{topic_id}", params)
  end

  # Attachment

  @doc """
  Upload an attachment file.
  """
  def upload_attachment(auth, topic_id, filepath) do
    post_file(auth, "topics/#{topic_id}/attachments", filepath)
  end

  @doc """
  Download an attachment file.
  """
  def download_attachment(auth, topic_id, post_id, attachment_id, filename) do
    get(auth, "topics/#{topic_id}/posts/#{post_id}/attachments/#{attachment_id}/#{filename}")
  end

  # Topic

  @doc """
  Returns topic members.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-topic-members)
  """
  def get_topic_members(auth, topic_id) do
    get(auth, "topics/#{topic_id}/members/status")
  end

  @doc """
  Returns a topic message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-message)
  """
  def get_message(auth, topic_id, post_id) do
    get(auth, "topics/#{topic_id}/posts/#{post_id}")
  end

  @doc """
  Update a topic message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/update-message)
  """
  def update_message(auth, topic_id, post_id, message) do
    put(auth, "topics/#{topic_id}/posts/#{post_id}", %{"message" => message})
  end

  @doc """
  Delete a topic message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/delete-message)
  """
  def delete_message(auth, topic_id, post_id) do
    delete(auth, "topics/#{topic_id}/posts/#{post_id}")
  end

  # Like

  @doc """
  Give a like to a message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/like-message)
  """
  def like_message(auth, topic_id, post_id) do
    post(auth, "topics/#{topic_id}/posts/#{post_id}/like")
  end

  @doc """
  Delete a like from a message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/unlike-message)
  """
  def unlike_message(auth, topic_id, post_id) do
    delete(auth, "topics/#{topic_id}/posts/#{post_id}/like")    
  end

  # Favorite topic

  @doc """
  Mark a topic as favorite.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/favorite-topic)
  """
  def favorite_topic(auth, topic_id) do
    post(auth, "topics/#{topic_id}/favorite")
  end

  @doc """
  Remove a topic from favorite.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/unfavorite-topic)
  """
  def unfavorite_topic(auth, topic_id) do
    delete(auth, "topics/#{topic_id}/favorite")
  end

  # Direct messages

  @doc """
  Get direct messages from an account.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-direct-messages)
  """
  def get_direct_messages(auth, account_name, options \\ []) do
    data = Keyword.merge([direction: "forward"], options)
    account = URI.encode("@#{account_name}")
    get(auth, "messages/#{account}", data)
  end

  @doc """
  Post a direct message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/post-direct-message)
  """
  def post_direct_message(auth, account_name, message, options) do
    data = options |> Keyword.merge([message: message])
    post(auth, "messages/@#{account_name}", data)
  end

  # Notifications

  def get_notifications(auth) do
    get(auth, "notifications")
  end

  def get_notification_status(auth) do
    get(auth, "notifications/status")
  end

  def mark_notifications_as_read(auth) do
    put(auth, "notifications")    
  end

  # Mentions

  def get_mentions(auth, options \\ :empty) do
    get(auth, "mentions", options)
  end

  def mark_mention_as_read(auth, mention_id) do
    put(auth, "mentions/#{mention_id}")
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
         |> Enum.filter(fn({k,_v}) -> MapSet.member?(@update_topic_options, k) end)
         |> Keyword.merge([name: name])
    put(auth, "topics/#{topic_id}", data)
  end

  def delete_topic(auth, topic_id) do
    delete(auth, "topics/#{topic_id}")
  end

  def get_topic_details(auth, topic_id) do
    get(auth, "topics/#{topic_id}/details")
  end

  # No test
  def update_topic_members(auth, topic_id, params) do
    # [:addAccountIds, :addGroupIds, :invitationEmails, :invitationRoles, :removeAccountIds, :cancelSpaceInvitation, :removeGroupIds]
    post(auth, "topics/#{topic_id}/members/update", params)
  end

  # Spaces

  def get_spaces(auth) do
    get(auth, "spaces")
  end

  def get_space_members(auth, space_key) do
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

  def get_talks(auth, topic_id) do
    get(auth, "topics/#{topic_id}/talks")
  end

  def get_talk_messages(auth, topic_id, talk_id) do
    get(auth, "topics/#{topic_id}/talks/#{talk_id}/posts")
  end

  def create_talk(auth, topic_id, name, post_ids) do
    data = Enum.zip(post_ids, 0..(length(post_ids) - 1))
         |> Enum.reduce(%{"talkName" => name}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(auth, "topics/#{topic_id}/talks", data)
  end

  def update_talk(auth, topic_id, talk_id, name) do
    put(auth, "topics/#{topic_id}/talks/#{talk_id}", talkName: name)
  end

  def delete_talk(auth, topic_id, talk_id) do
    delete(auth, "topics/#{topic_id}/talks/#{talk_id}")
  end

  def add_messages_to_talk(auth, topic_id, talk_id, post_ids) do
    data = Enum.zip(post_ids, 0..(length(post_ids) - 1))
         |> Enum.reduce(%{}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(auth, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
  end

  def delete_messages_from_talk(auth, topic_id, talk_id, post_ids) do
    data = [postIds: Enum.join(post_ids, ",")]
    delete(auth, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
  end
end
