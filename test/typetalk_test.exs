defmodule TypeTalkTest do
  use ExUnit.Case
  doctest TypeTalk

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  defp access_token(options \\ []) do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret,
      scope: Keyword.get(options, :scope, "my,topic.read,topic.post")
    )
    json    
  end

  defp get_topic(auth) do
    {:ok, res} = TypeTalk.get_topics(auth)
    topic = Enum.at(res["topics"], 0)
    topic["topic"]
  end

  defp get_topic_posts(auth, topic_id) do
    {:ok, res} = TypeTalk.topic_posts(auth, topic_id)
    res
  end

  defp get_topic_post(auth) do
    topic = get_topic(auth)
    posts = get_topic_posts(auth, topic["id"])
    post = Enum.at(posts["posts"], 0)
    {:ok, res} = TypeTalk.topic_post(auth, topic["id"], post["id"])
    res
  end

  test "access_token" do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret
    )
    assert json["access_token"] != nil
  end

  test "get profile" do
    token = access_token()
    {:ok, profile} = TypeTalk.get_profile(token)
    assert profile["account"] != nil
  end

  test "get friend profile" do
    token = access_token()
    {:ok, profile} = TypeTalk.get_friend_profile(token, "shimokawa")
    assert profile["account"] != nil    
  end

  test "get online status" do
    token = access_token()
    {:ok, profile} = TypeTalk.get_friend_profile(token, "shimokawa")
    {_, json} = TypeTalk.get_online_status(token, [profile["account"]["id"]])
    assert json["accounts"] != nil
    assert length(json["accounts"]) == 1
  end

  test "topics" do
    token = access_token()
    {:ok, res} = TypeTalk.get_topics(token)
    assert res["topics"] != nil
  end

  test "messages" do
    token = access_token()
    {:ok, res} = TypeTalk.messages(token)
    assert res["topics"] != nil
  end

  test "topic posts" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_posts(token, topic["id"])
    assert res["posts"] != nil
  end

  test "create topic post" do
    auth = access_token()
    topic = get_topic(auth)
    topic_id = topic["id"]
    message = "なんでやねん #{:os.system_time(:millisecond)}"
    {:ok, res} = TypeTalk.create_topic_post(auth, topic_id, message)
    assert res["post"]["message"] == message
  end

  test "topic members" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_members(token, topic["id"])
    assert res["accounts"] != nil
  end

  test "topic post" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_posts(token, topic["id"])
    post = Enum.at(res["posts"], 0)
    {:ok, res} = TypeTalk.topic_post(token, topic["id"], post["id"])
    assert res["post"] != nil
  end

  test "update topic post" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_posts(token, topic["id"])
    post = Enum.at(res["posts"], 0)
    message = post["message"]
    new_message = message <> " a"
    {:ok, res} = TypeTalk.update_topic_post(token, topic["id"], post["id"], new_message)
    assert res["post"]["message"] == new_message
  end

  test "delete topic post" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, created} = TypeTalk.create_topic_post(auth, topic["id"], "Hello")
    {:ok, deleted} = TypeTalk.delete_topic_post(auth, topic["id"], created["post"]["id"])
    assert deleted["id"] == created["post"]["id"]
  end

  # Like

  test "create like" do
    auth = access_token()
    post = get_topic_post(auth)
    TypeTalk.delete_like(auth, post["topic"]["id"], post["post"]["id"])
    {:ok, res} = TypeTalk.create_like(auth, post["topic"]["id"], post["post"]["id"])
    assert res["like"] != nil
  end

  test "delete like" do
    auth = access_token()
    post = get_topic_post(auth)
    TypeTalk.delete_like(auth, post["topic"]["id"], post["post"]["id"])
    {:ok, _}   = TypeTalk.create_like(auth, post["topic"]["id"], post["post"]["id"])
    {:ok, res} = TypeTalk.delete_like(auth, post["topic"]["id"], post["post"]["id"])
    assert res["like"] != nil
  end

  # Favorite topic

  test "add topic to favorite" do
    auth = access_token()
    topic = get_topic(auth)
    TypeTalk.delete_from_favorite(auth, topic["id"])

    {:ok, res} = TypeTalk.add_to_favorite(auth, topic["id"])
    assert res["favorite"] == true
  end

  test "delete topic from favorite" do
    auth = access_token()
    topic = get_topic(auth)
    TypeTalk.delete_from_favorite(auth, topic["id"])
    
    {:ok, _} = TypeTalk.add_to_favorite(auth, topic["id"])
    {:ok, res} = TypeTalk.delete_from_favorite(auth, topic["id"])
    assert res["favorite"] == false
  end
end
