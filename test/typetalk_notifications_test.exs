defmodule TypeTalkTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "get notifications" do
    auth = access_token()
    {:ok, res} = TypeTalk.notifications(auth)
    assert res["mentions"] != nil
  end
end
