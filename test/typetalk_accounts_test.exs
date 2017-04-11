defmodule TypetalkAccountsTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "get friends" do
    auth = access_token()
    {:ok, res} = Typetalk.search_friends(auth, "a")
    assert res["accounts"] != nil
  end

  test "search account" do
    auth = access_token()
    {:ok, res} = Typetalk.search_account(auth, "shimokawa")
    assert res["id"] != nil
  end
end
