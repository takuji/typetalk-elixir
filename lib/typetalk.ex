defmodule TypeTalk do
  import TypeTalk.Util
  
  @moduledoc """
  Documentation for TypeTalk.
  """
  @type auth :: Map | binary

  @api_base "https://typetalk.in/api/v1"

  defp get(auth, path) do
    _get(auth, "#{@api_base}/#{path}")
  end

  defp get(auth, path, params) do
     _get(auth, "#{@api_base}/#{path}?#{URI.encode_query(params)}")
  end

  defp _get(auth, url) do
    url
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

  defp put(auth, path) do
    _put(auth, "#{@api_base}/#{path}")
  end

  defp put(auth, path, params) do
    _put(auth, "#{@api_base}/#{path}?#{URI.encode_query(params)}")
  end

  defp _put(auth, url) do
    url 
    |> HTTPoison.put("", auth_header(auth))
    |> handle_response
  end

  defp delete(auth, path) do
    _delete(auth, "#{@api_base}/#{path}")
  end

  defp delete(auth, path, params) do
    _delete(auth, "#{@api_base}/#{path}?#{URI.encode_query(params)}")
  end

  defp _delete(auth, url) do
    url
    |> HTTPoison.delete(auth_header(auth))
    |> handle_response
  end

  @doc """
  Returns the profile of the caller.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-profile)
  """
  @spec get_profile(auth) :: {:ok, map}|{:error, map}
  def get_profile(auth) do
    get(auth, "profile")
  end

  @doc """
  Returns the profile of the given account name.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-friend-profile)
  """
  @spec get_friend_profile(auth, String.t) :: {:ok, map}|{:error, map}
  def get_friend_profile(auth, account_name) do
    get(auth, "accounts/profile/#{account_name}")
  end

  @doc """
  Returns the online status of accounts.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-online-status)
  """
  @spec get_online_status(auth, [integer]) :: {:ok, map}|{:error, map}
  def get_online_status(auth, account_ids) do
    q = Enum.join(account_ids, ",")
    get(auth, "accounts/status", %{"accountIds" => q})
  end

  @doc """
  Returns the topics.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-topics)
  """
  @spec get_topics(auth) :: {:ok, map}|{:error, map}
  def get_topics(auth) do
    get(auth, "topics")
  end

  @doc """
  Returns direct message topics.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-dm-topics)
  """
  @spec get_dm_topics(auth) :: {:ok, map}|{:error, map}
  def get_dm_topics(auth) do
    get(auth, "messages")
  end

  @doc """
  Returns messages of a topic.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-messages)
  """
  @spec get_messages(auth, String.t) :: {:ok, map}|{:error, map}
  def get_messages(auth, topic_id) do
    get(auth, "topics/#{topic_id}")
  end

  @doc """
  Post a message to a topic.

  ### options
  - `:replyTo`
  - `:showLinkMeta`
  - `:fileKeys`
  - `:talkIds`
  - `:attachmentFileUrls`
  - `:attachmentFileNames`

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/post-message)
  """
  @spec post_message(auth, binary, binary, Keyword.t) :: {:ok, map}|{:error, map}
  def post_message(auth, topic_id, message, options \\ []) do
    params = message_options(options) |> Keyword.merge([message: message])
    post(auth, "topics/#{topic_id}", params)
  end

  defp message_options(options) do
    Enum.reduce(options, [], &convert_message_option/2)
  end

  defp convert_message_option(option, acc) do
    case option do
      {:fileKeys, keys} ->
        acc ++ make_indexed_params("fileKeys", keys)
      {:talkIds, ids} ->
        acc ++ make_indexed_params("talkIds", ids)
      {:attachmentFileUrls, urls} ->
        acc ++ make_attachment_file_urls(urls)
      {:attachmentFileNames, names} ->
        acc ++ make_attachment_file_names(names)
      _ ->
        acc ++ [option]
    end
  end

  defp make_attachment_file_urls(values) do
    Enum.zip(values, 0..(length(values)-1))
    |> Enum.map(fn {value, idx} -> {:"attachments[#{idx}].fileUrl", value} end)
  end

  defp make_attachment_file_names(values) do
    Enum.zip(values, 0..(length(values)-1))
    |> Enum.map(fn {value, idx} -> {:"attachments[#{idx}].fileName", value} end)
  end

  # Attachment

  @doc """
  Upload an attachment file.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/update-attachment)
  """
  @spec upload_attachment(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def upload_attachment(auth, topic_id, filepath) do
    post_file(auth, "topics/#{topic_id}/attachments", filepath)
  end

  @doc """
  Download an attachment file.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/download-attachment)
  """
  @spec download_attachment(auth, String.t, String.t, String.t, String.t) :: {:ok, map}|{:error, map}
  def download_attachment(auth, topic_id, post_id, attachment_id, filename) do
    get(auth, "topics/#{topic_id}/posts/#{post_id}/attachments/#{attachment_id}/#{filename}")
  end

  # Topic

  @doc """
  Returns topic members.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-topic-members)
  """
  @spec get_topic_members(auth, String.t) :: {:ok, map}|{:error, map}
  def get_topic_members(auth, topic_id) do
    get(auth, "topics/#{topic_id}/members/status")
  end

  @doc """
  Returns a topic message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-message)
  """
  @spec get_message(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def get_message(auth, topic_id, post_id) do
    get(auth, "topics/#{topic_id}/posts/#{post_id}")
  end

  @doc """
  Update a topic message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/update-message)
  """
  @spec update_message(auth, String.t, String.t, String.t) :: {:ok, map}|{:error, map}
  def update_message(auth, topic_id, post_id, message) do
    put(auth, "topics/#{topic_id}/posts/#{post_id}", %{"message" => message})
  end

  @doc """
  Delete a topic message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/delete-message)
  """
  @spec delete_message(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def delete_message(auth, topic_id, post_id) do
    delete(auth, "topics/#{topic_id}/posts/#{post_id}")
  end

  # Like

  @doc """
  Give a like to a message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/like-message)
  """
  @spec like_message(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def like_message(auth, topic_id, post_id) do
    post(auth, "topics/#{topic_id}/posts/#{post_id}/like")
  end

  @doc """
  Delete a like from a message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/unlike-message)
  """
  @spec unlike_message(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def unlike_message(auth, topic_id, post_id) do
    delete(auth, "topics/#{topic_id}/posts/#{post_id}/like")    
  end

  # Favorite topic

  @doc """
  Mark a topic as favorite.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/favorite-topic)
  """
  @spec favorite_topic(auth, String.t) :: {:ok, map}|{:error, map}
  def favorite_topic(auth, topic_id) do
    post(auth, "topics/#{topic_id}/favorite")
  end

  @doc """
  Remove a topic from favorite.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/unfavorite-topic)
  """
  @spec unfavorite_topic(auth, String.t) :: {:ok, map}|{:error, map}
  def unfavorite_topic(auth, topic_id) do
    delete(auth, "topics/#{topic_id}/favorite")
  end

  # Direct messages

  @doc """
  Get direct messages from an account.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-direct-messages)
  """
  @spec get_direct_messages(auth, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def get_direct_messages(auth, account_name, options \\ []) do
    data = Keyword.merge([direction: "forward"], options)
    account = URI.encode("@#{account_name}")
    get(auth, "messages/#{account}", data)
  end

  @doc """
  Post a direct message.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/post-direct-message)
  """
  @spec post_direct_message(auth, String.t, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def post_direct_message(auth, account_name, message, options) do
    data = options |> Keyword.merge([message: message])
    post(auth, "messages/@#{account_name}", data)
  end

  # Notifications

  @doc """
  Get notifications.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-notifications)
  """
  @spec get_notifications(auth) :: {:ok, map}|{:error, map}
  def get_notifications(auth) do
    get(auth, "notifications")
  end

  @doc """
  Get notification status.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-notification-status)
  """
  @spec get_notification_status(auth) :: {:ok, map}|{:error, map}
  def get_notification_status(auth) do
    get(auth, "notifications/status")
  end

  @doc """
  Mark notifications as read.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/open-notification)
  """
  @spec mark_notifications_as_read(auth) :: {:ok, map}|{:error, map}
  def mark_notifications_as_read(auth) do
    put(auth, "notifications")    
  end

  # Mentions

  @doc """
  Returns mentions

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-mentions)
  """
  @spec get_mentions(auth) :: {:ok, map}|{:error, map}
  def get_mentions(auth) do
    get(auth, "mentions")
  end

  @doc """
  Returns mentions

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-mentions)
  """
  @spec get_mentions(auth, Keyword.t) :: {:ok, map}|{:error, map}
  def get_mentions(auth, options) do
    get(auth, "mentions", options)
  end

  @doc """
  Mark a mention as read.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-mentions)
  """
  @spec mark_mention_as_read(auth, String.t) :: {:ok, map}|{:error, map}
  def mark_mention_as_read(auth, mention_id) do
    put(auth, "mentions/#{mention_id}")
  end

  # Topics

  @doc """
  Mark all messages in a mention as read.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/save-read-mention)
  """
  @spec mark_topic_as_read(auth, String.t) :: {:ok, map}|{:error, map}
  def mark_topic_as_read(auth, topic_id) do
    put(auth, "bookmarks", topicId: topic_id)
  end

  @doc """
  Mark all messages in a mention as read.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/save-read-mention)
  """
  @spec mark_topic_as_read(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def mark_topic_as_read(auth, topic_id, post_id) do
    put(auth, "bookmarks", topicId: topic_id, postId: post_id)
  end

  @doc """
  Create a new topic.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/create-topic)
  """
  @spec create_topic(auth, String.t, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def create_topic(auth, name, space_key, options \\ %{}) do
    params = Enum.into(options, [name: name, spaceKey: space_key])
    post(auth, "topics", params)
  end

  @update_topic_options MapSet.new([:description])

  @doc """
  Update a topic name.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/update-topic)
  """
  @spec update_topic(auth, String.t, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def update_topic(auth, topic_id, name, options \\ []) do
    data = options
         |> Enum.filter(fn({k,_v}) -> MapSet.member?(@update_topic_options, k) end)
         |> Keyword.merge([name: name])
    put(auth, "topics/#{topic_id}", data)
  end

  @doc """
  Delete a topic.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/delete-topic)
  """
  @spec delete_topic(auth, String.t) :: {:ok, map}|{:error, map}
  def delete_topic(auth, topic_id) do
    delete(auth, "topics/#{topic_id}")
  end

  @doc """
  Returns topic information.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-topic-details)
  """
  @spec get_topic_details(auth, String.t) :: {:ok, map}|{:error, map}
  def get_topic_details(auth, topic_id) do
    get(auth, "topics/#{topic_id}/details")
  end

  # No test
  @doc """
  Update topic members.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/update-topic-members)
  """
  @spec update_topic_members(auth, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def update_topic_members(auth, topic_id, params) do
    # [:addAccountIds, :addGroupIds, :invitationEmails, :invitationRoles, :removeAccountIds, :cancelSpaceInvitation, :removeGroupIds]
    post(auth, "topics/#{topic_id}/members/update", params)
  end

  # Spaces

  @doc """
  Returns the space information.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-spaces)
  """
  @spec get_spaces(auth) :: {:ok, map}|{:error, map}
  def get_spaces(auth) do
    get(auth, "spaces")
  end

  @doc """
  Returns space members.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-space-members)
  """
  @spec get_space_members(auth, String.t) :: {:ok, map}|{:error, map}
  def get_space_members(auth, space_key) do
    get(auth, "spaces/#{space_key}/members")
  end

  # Search accounts

  @doc """
  Searches friends.

  Options
    * `:offset`
    * `:count`

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-friends)
  """
  @spec search_friends(auth, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def search_friends(auth, q, options \\ []) do
    params = %{
      q: q,
      offset: Keyword.get(options, :offset, 0),
      count: Keyword.get(options, :count, 30)
    }
    get(auth, "search/friends", params)
  end

  @doc """
  Get information of an account.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/search-accounts)
  """
  @spec search_account(auth, String.t) :: {:ok, map}|{:error, map}
  def search_account(auth, name_or_email) do
    get(auth, "search/accounts", [nameOrEmailAddress: name_or_email])
  end

  # Talks

  @doc """
  Returns talks of a topic.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-talks)
  """
  @spec get_talks(auth, String.t) :: {:ok, map}|{:error, map}
  def get_talks(auth, topic_id) do
    get(auth, "topics/#{topic_id}/talks")
  end

  @doc """
  Returns messages of a talk.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/get-talk-messages)
  """
  @spec get_talk_messages(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def get_talk_messages(auth, topic_id, talk_id) do
    get(auth, "topics/#{topic_id}/talks/#{talk_id}/posts")
  end

  @doc """
  Creates a new talk.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/create-talk)
  """
  @spec create_talk(auth, String.t, String.t, [integer]) :: {:ok, map}|{:error, map}
  def create_talk(auth, topic_id, name, post_ids) do
    data = Enum.zip(post_ids, 0..(length(post_ids) - 1))
         |> Enum.reduce(%{"talkName" => name}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(auth, "topics/#{topic_id}/talks", data)
  end

  @doc """
  Changes a talk's name.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/update-talk)
  """
  @spec update_talk(auth, String.t, String.t, String.t) :: {:ok, map}|{:error, map}
  def update_talk(auth, topic_id, talk_id, name) do
    put(auth, "topics/#{topic_id}/talks/#{talk_id}", talkName: name)
  end

  @doc """
  Deletes a talk.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/delete-talk)
  """
  @spec delete_talk(auth, String.t, String.t) :: {:ok, map}|{:error, map}
  def delete_talk(auth, topic_id, talk_id) do
    delete(auth, "topics/#{topic_id}/talks/#{talk_id}")
  end

  @doc """
  Add messages to a talk.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/add-memssage-to-talk)
  """
  @spec add_messages_to_talk(auth, String.t, String.t, [integer]) :: {:ok, map}|{:error, map}
  def add_messages_to_talk(auth, topic_id, talk_id, post_ids) do
    data = Enum.zip(post_ids, 0..(length(post_ids) - 1))
         |> Enum.reduce(%{}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(auth, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
  end

  @doc """
  Deletes messages from a talk.

  [API Doc](https://developer.nulab-inc.com/docs/typetalk/api/1/remove-memssage-from-talk)
  """
  @spec delete_messages_from_talk(auth, String.t, String.t, [integer]) :: {:ok, map}|{:error, map}
  def delete_messages_from_talk(auth, topic_id, talk_id, post_ids) do
    data = [postIds: Enum.join(post_ids, ",")]
    delete(auth, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
  end
end
