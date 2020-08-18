defmodule TypetalkAccountsTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "get friends" do
    auth = access_token()
    space = get_space(auth)
    {:ok, res} = Typetalk.search_friends(auth, space["key"], "a")
    assert res["accounts"] != nil
  end
end
