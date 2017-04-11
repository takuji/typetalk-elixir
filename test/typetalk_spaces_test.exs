defmodule TypetalkSpacesTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "get spaces" do
    auth = access_token()
    {:ok, res} = Typetalk.get_spaces(auth)
    assert res["mySpaces"] != nil
  end

  test "get space members" do
    auth = access_token()
    space = get_space(auth)
    {:ok, res} = Typetalk.get_space_members(auth, space["space"]["key"])
    assert res["accounts"] != nil
  end
end
