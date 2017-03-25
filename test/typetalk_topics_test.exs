defmodule TypeTalkTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "mark topic as read" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = TypeTalk.mark_topic_as_read(auth, topic["id"])
    assert res["unread"] != nil
  end
end
