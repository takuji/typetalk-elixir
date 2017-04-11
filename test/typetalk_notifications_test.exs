defmodule TypetalkNotificationsTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "get notifications" do
    auth = access_token()
    {:ok, res} = Typetalk.get_notifications(auth)
    assert res["mentions"] != nil
  end

  test "get unread notifications counts" do
    auth = access_token()
    {:ok, res} = Typetalk.get_notification_status(auth)
    assert res["mention"] != nil
  end

  test "mark notifications as read" do
    auth = access_token()
    {:ok, res} = Typetalk.mark_notifications_as_read(auth)
    assert res["access"] != nil
  end
end
