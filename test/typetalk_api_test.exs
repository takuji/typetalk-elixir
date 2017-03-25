defmodule TypeTalkTest do
  use ExUnit.Case
  doctest TypeTalk

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  defp access_token(options \\ []) do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret,
      scope: Keyword.get(options, :scope, "my")
    )
    json    
  end

  defp account() do
  end

  defp get_topic(auth) do
    {:ok, res} = TypeTalk.topics(auth)
    topic = Enum.at(res["topics"], 0)
    topic["topic"]
  end

  test "access_token" do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret
    )
    assert json["access_token"] != nil
  end

  test "profile" do
    token = access_token()
    {:ok, profile} = TypeTalk.profile(token)
    assert profile["account"] != nil
  end

  test "account profile" do
    token = access_token()
    {:ok, profile} = TypeTalk.account_profile(token, "shimokawa")
    assert profile["account"] != nil    
  end

  test "account status" do
    token = access_token()
    {:ok, profile} = TypeTalk.account_profile(token, "shimokawa")
    {status, json} = TypeTalk.accounts_status(token, [profile["account"]["id"]])
    assert json["accounts"] != nil    
  end

  test "topics" do
    token = access_token()
    {:ok, res} = TypeTalk.topics(token)
    assert res["topics"] != nil
  end

  test "messages" do
    token = access_token()
    {:ok, res} = TypeTalk.messages(token)
    assert res["topics"] != nil
  end

  test "topic posts" do
    token = access_token(scope: "my,topic.read")
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_posts(token, topic["id"])
    assert res["posts"] != nil
  end

  test "create topic post" do
    auth = access_token(scope: "my,topic.read,topic.post")
    {:ok, res} = TypeTalk.topics(auth)
    topic = get_topic(auth)
    topic_id = topic["id"]
    {:ok, res} = TypeTalk.topic_posts(auth, topic_id)
    n1 = length(res["posts"])
    message = "なんでやねん"
    {:ok, res} = TypeTalk.create_topic_post(auth, topic_id, message)
    assert res["post"]["message"] == message
    {:ok, res} = TypeTalk.topic_posts(auth, topic_id)
    n2 = length(res["posts"])
    assert n2 == (n1 + 1)
  end

  test "topic members" do
    token = access_token(scope: "topic.read,my")
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_members(token, topic["id"])
    assert res["accounts"] != nil
  end

  test "topic post" do
    token = access_token(scope: "topic.read,my")
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_posts(token, topic["id"])
    post = Enum.at(res["posts"], 0)
    {:ok, res} = TypeTalk.topic_post(token, topic["id"], post["id"])
    assert res["post"] != nil
  end

  test "update topic post" do
    token = access_token(scope: "my,topic.read,topic.post")
    topic = get_topic(token)
    {:ok, res} = TypeTalk.topic_posts(token, topic["id"])
    post = Enum.at(res["posts"], 0)
    message = post["message"]
    new_message = message <> " a"
    {:ok, res} = TypeTalk.update_topic_post(token, topic["id"], post["id"], new_message)
    assert res["post"]["message"] == new_message
  end

  defp get_topic_posts(auth, topic_id) do
    {:ok, res} = TypeTalk.topic_posts(auth, topic_id)
    res["posts"]
  end

  test "delete topic post" do
    auth = access_token(scope: "my,topic.read,topic.post")
    topic = get_topic(auth)
    {:ok, created} = TypeTalk.create_topic_post(auth, topic["id"], "Hello")
    n1 = length(get_topic_posts(auth, topic["id"]))

    {:ok, deleted} = TypeTalk.delete_topic_post(auth, topic["id"], created["post"]["id"])
    assert deleted["id"] == created["post"]["id"]

    n2 = length(get_topic_posts(auth, topic["id"]))
    assert n2 == (n1 - 1)
  end
end
