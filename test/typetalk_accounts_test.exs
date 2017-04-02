defmodule TypeTalkTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "get friends" do
    auth = access_token()
    {:ok, res} = TypeTalk.search_friends(auth, "a")
    assert res["accounts"] != nil
  end

  test "search account" do
    auth = access_token()
    {:ok, res} = TypeTalk.search_account(auth, "shimokawa")
    assert res["id"] != nil
  end
end
