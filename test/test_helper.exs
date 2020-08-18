defmodule TypetalkTestHelper do
  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  def access_token(options \\ []) do
    {:ok, json} = Typetalk.ClientCredential.access_token(
      @client_id,
      @client_secret,
      Keyword.get(options, :scope, "my,topic.read,topic.post")
    )
    json    
  end

  def get_topic(auth) do
    space = get_space(auth)
    {:ok, res} = Typetalk.get_topics(auth, space["key"])
    topic = Enum.at(res["topics"], 0)
    topic["topic"]
  end

  def get_messages(auth, topic_id) do
    {:ok, res} = Typetalk.get_messages(auth, topic_id)
    res
  end

  def get_message(auth) do
    topic = get_topic(auth)
    posts = get_messages(auth, topic["id"])
    post = Enum.at(posts["posts"], 0)
    {:ok, res} = Typetalk.get_message(auth, topic["id"], post["id"])
    res
  end

  def get_space(auth) do
    {:ok, res} = Typetalk.get_spaces(auth)
    Enum.at(res["mySpaces"], 0)["space"]
  end
end

ExUnit.start()
