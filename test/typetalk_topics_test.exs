defmodule TypeTalkTopicsTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "mark topic as read" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = TypeTalk.mark_topic_as_read(auth, topic["id"])
    assert res["unread"] != nil
  end

  test "create and delete a topic" do
    auth = access_token(scope: "my,topic.write,topic.delete")
    name = "TEST TOPIC #{:os.system_time(:millisecond)}"
    space = get_space(auth)
    {:ok, created} = TypeTalk.create_topic(auth, name, space["space"]["key"])
    assert created["topic"] != nil
    
    {:ok, deleted} = TypeTalk.delete_topic(auth, created["topic"]["id"])
    assert deleted["id"] == created["topic"]["id"]
  end

  test "update a topic" do
    auth = access_token(scope: "my,topic.write,topic.delete")
    name = "TEST TOPIC #{:os.system_time(:millisecond)}"
    space = get_space(auth)
    {:ok, created} = TypeTalk.create_topic(auth, name, space["space"]["key"])
    assert created["topic"] != nil
    
    name = created["topic"]["name"] <> ":updated"
    description = "Updated description"
    {:ok, updated} = TypeTalk.update_topic(auth, created["topic"]["id"], name, description: description)
    assert updated["topic"]["name"] == name

    {:ok, _} = TypeTalk.delete_topic(auth, created["topic"]["id"])
  end

  test "get topic details" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = TypeTalk.topic_details(auth, topic["id"])
    assert res["topic"] != nil
  end
end
