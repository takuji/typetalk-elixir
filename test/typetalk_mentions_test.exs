defmodule TypetalkMentionsTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "get mentions" do
    auth = access_token()
    space = get_space(auth)
    {:ok, res} = Typetalk.get_mentions(auth, space["key"])
    assert res["mentions"] != nil
  end

  test "mark mention as read" do
    auth = access_token()
    space = get_space(auth)
    {:ok, res} = Typetalk.get_mentions(auth, space["key"])
    mention = Enum.at(res["mentions"], 0)
    {:ok, res} = Typetalk.mark_mention_as_read(auth, mention["id"])
    assert res["mention"] != nil
  end
end
