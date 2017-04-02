defmodule TypeTalkTestHelper do
  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  def access_token(options \\ []) do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret,
      scope: Keyword.get(options, :scope, "my,topic.read,topic.post")
    )
    json    
  end

  def get_topic(auth) do
    {:ok, res} = TypeTalk.get_topics(auth)
    topic = Enum.at(res["topics"], 0)
    topic["topic"]
  end

  def get_topic_posts(auth, topic_id) do
    {:ok, res} = TypeTalk.topic_posts(auth, topic_id)
    res
  end

  def get_topic_post(auth) do
    topic = get_topic(auth)
    posts = get_topic_posts(auth, topic["id"])
    post = Enum.at(posts["posts"], 0)
    {:ok, res} = TypeTalk.topic_post(auth, topic["id"], post["id"])
    res
  end

  def get_space(auth) do
    {:ok, res} = TypeTalk.spaces(auth)
    Enum.at(res["mySpaces"], 0)
  end
end

ExUnit.start()
