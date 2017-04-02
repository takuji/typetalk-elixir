defmodule TypeTalkMentionsTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "get mentions" do
    auth = access_token()
    {:ok, res} = TypeTalk.get_mentions(auth)
    assert res["mentions"] != nil
  end

  test "mark mention as read" do
    auth = access_token()
    {:ok, res} = TypeTalk.get_mentions(auth)
    mention = Enum.at(res["mentions"], 0)
    {:ok, res} = TypeTalk.mark_mention_as_read(auth, mention["id"])
    assert res["mention"] != nil
  end
end
