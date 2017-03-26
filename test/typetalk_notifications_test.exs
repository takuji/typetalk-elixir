defmodule TypeTalkTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "get notifications" do
    auth = access_token()
    {:ok, res} = TypeTalk.notifications(auth)
    assert res["mentions"] != nil
  end

  test "get unread notifications counts" do
    auth = access_token()
    {:ok, res} = TypeTalk.notifications_status(auth)
    assert res["mention"] != nil
  end

  test "mark notifications as read" do
    auth = access_token()
    {:ok, res} = TypeTalk.mark_notifications_as_read(auth)
    assert res["access"] != nil
  end
end