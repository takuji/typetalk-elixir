defmodule Typetalk do
  import Typetalk.Util
  
  @moduledoc """
  A [Typetalk](https://typetalk.com) API client library.

  [API Doc](https://developer.nulab.com/docs/typetalk)
  """
  @type token :: access_token | type_talk_token
  @type type_talk_token :: binary
  @type access_token :: Typetalk.AccessToken.t

  @api_base "https://typetalk.com/api/v1"
  @api_v_base "https://typetalk.com/api/v"

  defp get(token, path, params \\ []) do
    u = build_url(path, params)
    IO.puts(u)
    build_url(path, params)
    |> HTTPoison.get(auth_header(token))
    |> handle_response
  end

  defp get_v(v, token, path, params \\ []) do
    u = build_url_v(v, path, params)
    IO.puts(u)
    u
    |> HTTPoison.get(auth_header(token))
    |> handle_response
  end

  defp get_v2(token, path, params) do
    get_v(2, token, path, params)
  end

  defp post(token, path, params \\ []) do
    {headers, data} = create_post_data(params)
    HTTPoison.post("#{@api_base}/#{path}", data, Map.merge(auth_header(token), headers))
    |> handle_response
  end

  defp create_post_data(params) do
    case params do
      [] -> {%{"Content-Type" => "application/x-www-form-urlencoded"}, ""}
      _ when is_binary(params) -> {%{"Content-Type" => "application/x-www-form-urlencoded"}, params}
      _ when is_list(params) -> {%{}, {:form, params}}
      # _ -> {%{}, Enum.into(params, [])}
    end
  end

  defp post_file(token, path, file) when is_binary(file) do
    data = {:multipart, [{:file, file}]}
    HTTPoison.post("#{@api_base}/#{path}", data, auth_header(token))
    |> handle_response
  end

  defp put(token, path, params \\ []) do
    {headers, data} = create_post_data(params)
    build_url(path, [])
    |> HTTPoison.put(data, Map.merge(auth_header(token), headers))
    |> handle_response
  end

  defp put_q(token, path, params \\ []) do
    build_url(path, params) # params are passed as query parameters
    |> HTTPoison.put("", auth_header(token))
    |> handle_response
  end

  defp put_v(v, token, path, params \\ []) do
    {headers, data} = create_post_data(params)
    build_url_v(v, path, [])
    |> HTTPoison.put(data, Map.merge(auth_header(token), headers))
    |> handle_response
  end

  defp delete(token, path, params \\ []) do
    build_url(path, params)
    |> HTTPoison.delete(auth_header(token))
    |> handle_response
  end

  defp build_url(path, query_params) do
    case query_params do
      [] -> "#{@api_base}/#{path}"
      _ -> "#{@api_base}/#{path}?#{URI.encode_query(query_params)}"
    end
  end

  defp build_url_v(v, path, query_params) do
    case query_params do
      [] -> "#{@api_v_base}#{v}/#{path}"
      _ -> "#{@api_v_base}#{v}/#{path}?#{URI.encode_query(query_params)}"
    end
  end

  # 
  # API
  # 

  @doc """
  Returns the profile of the caller.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-profile)
  """
  @spec get_profile(token) :: {:ok, map}|{:error, map}
  def get_profile(token) do
    get(token, "profile")
  end

  @doc """
  Returns the profile of the given account name.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/2/get-friend-profile)
  """
  @spec get_friend_profile(token, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def get_friend_profile(token, space_key, options \\ []) do
    params = message_options(options)
    get_v2(token, "spaces/#{space_key}/profile", params)
  end

  @doc """
  Returns the online status of accounts.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-online-status)
  """
  @spec get_online_status(token, [integer]) :: {:ok, map}|{:error, map}
  def get_online_status(token, account_ids) do
    q = Enum.join(account_ids, ",")
    get(token, "accounts/status", %{"accountIds" => q})
  end

  @doc """
  Returns the topics.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-topics)
  """
  @spec get_topics(token, String.t) :: {:ok, map}|{:error, map}
  def get_topics(token, space_key) do
    get_v2(token, "topics", %{"spaceKey" => space_key})
  end

  @doc """
  Returns direct message topics.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/2/get-dm-topics)
  """
  @spec get_dm_topics(token, String.t) :: {:ok, map}|{:error, map}
  def get_dm_topics(token, space_key) do
    get_v2(token, "messages", %{"spaceKey" => space_key})
  end

  @doc """
  Returns messages of a topic.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-messages)
  """
  @spec get_messages(token, String.t) :: {:ok, map}|{:error, map}
  def get_messages(token, topic_id) do
    get(token, "topics/#{topic_id}")
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

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/post-message)
  """
  @spec post_message(token, binary, binary, Keyword.t) :: {:ok, map}|{:error, map}
  def post_message(token, topic_id, message, options \\ []) do
    params = message_options(options) |> Keyword.merge([message: message])
    post(token, "topics/#{topic_id}", params)
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
    Enum.with_index(values)
    |> Enum.map(fn {value, idx} -> {:"attachments[#{idx}].fileUrl", value} end)
  end

  defp make_attachment_file_names(values) do
    Enum.with_index(values)
    |> Enum.map(fn {value, idx} -> {:"attachments[#{idx}].fileName", value} end)
  end

  # Attachment

  @doc """
  Upload an attachment file.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/update-attachment)
  """
  @spec upload_attachment(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def upload_attachment(token, topic_id, filepath) do
    post_file(token, "topics/#{topic_id}/attachments", filepath)
  end

  @doc """
  Download an attachment file.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/download-attachment)
  """
  @spec download_attachment(token, String.t, String.t, String.t, String.t) :: {:ok, map}|{:error, map}
  def download_attachment(token, topic_id, post_id, attachment_id, filename) do
    get(token, "topics/#{topic_id}/posts/#{post_id}/attachments/#{attachment_id}/#{filename}")
  end

  # Topic

  @doc """
  Returns topic members.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-topic-members)
  """
  @spec get_topic_members(token, String.t) :: {:ok, map}|{:error, map}
  def get_topic_members(token, topic_id) do
    get(token, "topics/#{topic_id}/members/status")
  end

  @doc """
  Returns a topic message.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-message)
  """
  @spec get_message(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def get_message(token, topic_id, post_id) do
    get(token, "topics/#{topic_id}/posts/#{post_id}")
  end

  @doc """
  Update a topic message.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/update-message)
  """
  @spec update_message(token, String.t, String.t, String.t) :: {:ok, map}|{:error, map}
  def update_message(token, topic_id, post_id, message) do
    put(token, "topics/#{topic_id}/posts/#{post_id}", message: message)
  end

  @doc """
  Delete a topic message.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/delete-message)
  """
  @spec delete_message(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def delete_message(token, topic_id, post_id) do
    delete(token, "topics/#{topic_id}/posts/#{post_id}")
  end

  @doc """
  You can search through posted messages with this API.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/2/search-messages)
  """
  def search_messages(token, q, space_key, options) do
    params = message_options(options) |> Keyword.merge([q: q, spaceKey: space_key])
    get_v2(token, "search/posts", params)
  end

  # Like

  @doc """
  Give a like to a message.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/like-message)
  """
  @spec like_message(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def like_message(token, topic_id, post_id) do
    post(token, "topics/#{topic_id}/posts/#{post_id}/like")
  end

  @doc """
  Delete a like from a message.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/unlike-message)
  """
  @spec unlike_message(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def unlike_message(token, topic_id, post_id) do
    delete(token, "topics/#{topic_id}/posts/#{post_id}/like")    
  end

  # Direct messages

  @doc """
  Get direct messages from an account.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/2/get-direct-messages)
  """
  @spec get_direct_messages(token, String.t, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def get_direct_messages(token, space_key, account_name, options \\ []) do
    data = Keyword.merge([direction: "forward"], options)
    account = URI.encode("@#{account_name}")
    get_v2(token, "spaces/#{space_key}/messages/#{account}", data)
  end

  @doc """
  Post a direct message.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/2/post-direct-message)
  """
  @spec post_direct_message(token, String.t, String.t, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def post_direct_message(token, space_key, account_name, message, options) do
    data = options |> Keyword.merge([message: message])
    post(token, "spaces/#{space_key}/messages/@#{account_name}", data)
  end

  # Notifications

  @doc """
  Get notification status.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/7/get-notification-status/)
  """
  @spec get_notification_status(token) :: {:ok, map}|{:error, map}
  def get_notification_status(token) do
    get_v(7, token, "notifications/status")
  end

  @doc """
  Mark notifications as read.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/3/open-notification)
  """
  @spec mark_notifications_as_read(token, String.t) :: {:ok, map}|{:error, map}
  def mark_notifications_as_read(token, space_key) do
    put_v(3, token, "notifications", spaceKey: space_key)    
  end

  # Mentions

  @doc """
  Returns mentions

  [API Doc](https://developer.nulab.com/docs/typetalk/api/2/get-mentions)
  """
  @spec get_mentions(token, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def get_mentions(token, space_key, options \\ []) do
    params = options |> Keyword.merge([spaceKey: space_key])
    get_v2(token, "mentions", params)
  end

  @doc """
  Mark a mention as read.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/save-read-mention)
  """
  @spec mark_mention_as_read(token, String.t) :: {:ok, map}|{:error, map}
  def mark_mention_as_read(token, mention_id) do
    put(token, "mentions/#{mention_id}")
  end

  # Topics

  @doc """
  Mark all messages in a topic as read.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/save-read-topic)
  """
  @spec mark_topic_as_read(token, String.t) :: {:ok, map}|{:error, map}
  def mark_topic_as_read(token, topic_id) do
    put_q(token, "bookmarks", topicId: topic_id)
  end

  @doc """
  Mark all messages in a topic as read.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/save-read-topic)
  """
  @spec mark_topic_as_read(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def mark_topic_as_read(token, topic_id, post_id) do
    put_q(token, "bookmarks", topicId: topic_id, postId: post_id)
  end

  @doc """
  Create a new topic.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/create-topic)
  """
  @spec create_topic(token, String.t, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def create_topic(token, name, space_key, options \\ []) do
    params = Enum.into(options, [name: name, spaceKey: space_key])
    post(token, "topics", params)
  end

  @update_topic_options MapSet.new([:description])

  @doc """
  Update a topic name.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/update-topic)
  """
  @spec update_topic(token, String.t, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def update_topic(token, topic_id, name, options \\ []) do
    data = options
         |> Enum.filter(fn({k,_v}) -> MapSet.member?(@update_topic_options, k) end)
         |> Keyword.merge([name: name])
    put(token, "topics/#{topic_id}", data)
  end

  @doc """
  Delete a topic.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/delete-topic)
  """
  @spec delete_topic(token, String.t) :: {:ok, map}|{:error, map}
  def delete_topic(token, topic_id) do
    delete(token, "topics/#{topic_id}")
  end

  @doc """
  Returns topic information.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-topic-details)
  """
  @spec get_topic_details(token, String.t) :: {:ok, map}|{:error, map}
  def get_topic_details(token, topic_id) do
    get(token, "topics/#{topic_id}/details")
  end

  # No test
  @doc """
  Update topic members.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/update-topic-members)
  """
  @spec update_topic_members(token, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def update_topic_members(token, topic_id, params) do
    # [:addAccountIds, :addGroupIds, :invitationEmails, :invitationRoles, :removeAccountIds, :cancelSpaceInvitation, :removeGroupIds]
    post(token, "topics/#{topic_id}/members/update", params)
  end

  # Spaces

  @doc """
  Returns the space information.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-spaces)
  """
  @spec get_spaces(token) :: {:ok, map}|{:error, map}
  def get_spaces(token) do
    get(token, "spaces")
  end

  @doc """
  Returns space members.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-space-members)
  """
  @spec get_space_members(token, String.t) :: {:ok, map}|{:error, map}
  def get_space_members(token, space_key) do
    get(token, "spaces/#{space_key}/members")
  end

  # Search accounts

  @doc """
  Searches friends.

  Options
    * `:offset`
    * `:count`

  [API Doc](https://developer.nulab.com/docs/typetalk/api/4/get-friends)
  """
  @spec search_friends(token, String.t, Keyword.t) :: {:ok, map}|{:error, map}
  def search_friends(token, space_key, q, options \\ []) do
    params = %{
      q: q,
      spaceKey: space_key,
      offset: Keyword.get(options, :offset, 0),
      count: Keyword.get(options, :count, 30)
    }
    get_v(4, token, "search/friends", params)
  end

  # Talks

  @doc """
  Returns talks of a topic.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-talks)
  """
  @spec get_talks(token, String.t) :: {:ok, map}|{:error, map}
  def get_talks(token, topic_id) do
    get(token, "topics/#{topic_id}/talks")
  end

  @doc """
  Returns messages of a talk.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/get-talk-messages)
  """
  @spec get_talk_messages(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def get_talk_messages(token, topic_id, talk_id) do
    get(token, "topics/#{topic_id}/talks/#{talk_id}/posts")
  end

  @doc """
  Creates a new talk.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/create-talk)
  """
  @spec create_talk(token, String.t, String.t, [integer]) :: {:ok, map}|{:error, map}
  def create_talk(token, topic_id, name, post_ids) do
    data = Enum.with_index(post_ids)
         |> Enum.reduce(%{"talkName" => name}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(token, "topics/#{topic_id}/talks", data)
  end

  @doc """
  Changes a talk's name.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/update-talk)
  """
  @spec update_talk(token, String.t, String.t, String.t) :: {:ok, map}|{:error, map}
  def update_talk(token, topic_id, talk_id, name) do
    put(token, "topics/#{topic_id}/talks/#{talk_id}", talkName: name)
  end

  @doc """
  Deletes a talk.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/delete-talk)
  """
  @spec delete_talk(token, String.t, String.t) :: {:ok, map}|{:error, map}
  def delete_talk(token, topic_id, talk_id) do
    delete(token, "topics/#{topic_id}/talks/#{talk_id}")
  end

  @doc """
  Add messages to a talk.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/add-memssage-to-talk)
  """
  @spec add_messages_to_talk(token, String.t, String.t, [integer]) :: {:ok, map}|{:error, map}
  def add_messages_to_talk(token, topic_id, talk_id, post_ids) do
    data = Enum.with_index(post_ids)
         |> Enum.reduce(%{}, fn ({post_id, idx}, acc) -> Map.put(acc, "postIds[#{idx}]", post_id) end)
         |> URI.encode_query()
    post(token, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
  end

  @doc """
  Deletes messages from a talk.

  [API Doc](https://developer.nulab.com/docs/typetalk/api/1/remove-memssage-from-talk)
  """
  @spec delete_messages_from_talk(token, String.t, String.t, [integer]) :: {:ok, map}|{:error, map}
  def delete_messages_from_talk(token, topic_id, talk_id, post_ids) do
    data = [postIds: Enum.join(post_ids, ",")]
    delete(token, "topics/#{topic_id}/talks/#{talk_id}/posts", data)
  end
end
