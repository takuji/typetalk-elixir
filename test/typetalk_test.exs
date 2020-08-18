defmodule TypetalkTest do
  use ExUnit.Case
  doctest Typetalk

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  defp access_token(options \\ []) do
    {:ok, json} = Typetalk.ClientCredential.access_token(@client_id,
                                                         @client_secret,
                                                         Keyword.get(options, :scope, "my,topic.read,topic.post"))
    json    
  end

  defp get_space(auth) do
    {:ok, spaces} = Typetalk.get_spaces(auth)
    Enum.at(spaces["mySpaces"], 0)["space"]
  end

  defp get_topic(auth) do
    space = get_space(auth)
    {:ok, res} = Typetalk.get_topics(auth, space["key"])
    topic = Enum.at(res["topics"], 0)
    topic["topic"]
  end

  defp get_messages(auth, topic_id) do
    {:ok, res} = Typetalk.get_messages(auth, topic_id)
    res
  end

  defp get_message(auth) do
    topic = get_topic(auth)
    posts = get_messages(auth, topic["id"])
    post = Enum.at(posts["posts"], 0)
    {:ok, res} = Typetalk.get_message(auth, topic["id"], post["id"])
    res
  end

  test "get profile" do
    token = access_token()
    {:ok, profile} = Typetalk.get_profile(token)
    assert profile["account"] != nil
  end

  test "get friend profile" do
    token = access_token()
    space = get_space(token)
    {:ok, profile} = Typetalk.get_friend_profile(token, space["key"], accountName: "shimokawa")
    assert profile["account"] != nil    
  end

  test "get online status" do
    token = access_token()
    space = get_space(token)
    {:ok, profile} = Typetalk.get_friend_profile(token, space["key"], accountName: "shimokawa")
    {_, json} = Typetalk.get_online_status(token, [profile["account"]["id"]])
    assert json["accounts"] != nil
    assert length(json["accounts"]) == 1
  end

  test "get topics" do
    token = access_token()
    space = get_space(token)
    {:ok, res} = Typetalk.get_topics(token, space["key"])
    assert res["topics"] != nil
  end

  test "get direct message topics" do
    token = access_token()
    space = get_space(token)
    {:ok, res} = Typetalk.get_dm_topics(token, space["key"])
    assert res["topics"] != nil
  end

  test "topic posts" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = Typetalk.get_messages(token, topic["id"])
    assert res["posts"] != nil
  end

  test "create topic post" do
    auth = access_token()
    topic = get_topic(auth)
    topic_id = topic["id"]
    message = "なんでやねん #{:os.system_time(:millisecond)}"
    {:ok, res} = Typetalk.post_message(auth, topic_id, message)
    assert res["post"]["message"] == message
  end

  test "topic members" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = Typetalk.get_topic_members(token, topic["id"])
    assert res["accounts"] != nil
  end

  test "topic post" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = Typetalk.get_messages(token, topic["id"])
    post = Enum.at(res["posts"], 0)
    {:ok, res} = Typetalk.get_message(token, topic["id"], post["id"])
    assert res["post"] != nil
  end

  test "update topic post" do
    token = access_token()
    topic = get_topic(token)
    {:ok, res} = Typetalk.get_messages(token, topic["id"])
    post = Enum.at(res["posts"], 0)
    message = post["message"]
    new_message = message <> " a"
    {:ok, res} = Typetalk.update_message(token, topic["id"], post["id"], new_message)
    assert res["post"]["message"] == new_message
  end

  test "delete topic post" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, created} = Typetalk.post_message(auth, topic["id"], "Hello")
    {:ok, deleted} = Typetalk.delete_message(auth, topic["id"], created["post"]["id"])
    assert deleted["id"] == created["post"]["id"]
  end

  # Like

  test "like message" do
    auth = access_token()
    post = get_message(auth)
    Typetalk.unlike_message(auth, post["topic"]["id"], post["post"]["id"])
    {:ok, res} = Typetalk.like_message(auth, post["topic"]["id"], post["post"]["id"])
    assert res["like"] != nil
  end

  test "unlike message" do
    auth = access_token()
    post = get_message(auth)
    Typetalk.unlike_message(auth, post["topic"]["id"], post["post"]["id"])
    {:ok, _}   = Typetalk.like_message(auth, post["topic"]["id"], post["post"]["id"])
    {:ok, res} = Typetalk.unlike_message(auth, post["topic"]["id"], post["post"]["id"])
    assert res["like"] != nil
  end
end