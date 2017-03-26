defmodule TypeTalkTopicsTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "mark topic as read" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = TypeTalk.mark_topic_as_read(auth, topic["id"])
    assert res["unread"] != nil
  end

  test "create a topic" do
    auth = access_token(scope: "my,topic.write")
    name = "TEST TOPIC #{:os.system_time(:millisecond)}"
    space = get_space(auth)
    {:ok, res} = TypeTalk.create_topic(auth, name, space["space"]["key"])
    assert res["topic"] != nil
  end
end
