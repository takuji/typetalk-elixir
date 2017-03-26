defmodule TypeTalkTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "get talks" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = TypeTalk.talks(auth, topic["id"])
    assert res["talks"] != nil
  end
end
