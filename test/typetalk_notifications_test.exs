defmodule TypetalkNotificationsTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "get unread notifications counts" do
    auth = access_token()
    {:ok, res} = Typetalk.get_notification_status(auth)
    assert res["statuses"] != nil
  end

  test "mark notifications as read" do
    auth = access_token()
    space = get_space(auth)
    {:ok, res} = Typetalk.mark_notifications_as_read(auth, space["key"])
    assert res["access"] != nil
  end
end
