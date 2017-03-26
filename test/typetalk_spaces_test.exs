defmodule TypeTalkTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "get spaces" do
    auth = access_token()
    {:ok, res} = TypeTalk.spaces(auth)
    assert res["mySpaces"] != nil
  end

  test "get space members" do
    auth = access_token()
    space = get_space(auth)
    {:ok, res} = TypeTalk.space_members(auth, space["space"]["key"])
    assert res["accounts"] != nil
  end
end