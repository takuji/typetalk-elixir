defmodule TypeTalk.UtilTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "make_indexed_params" do
    assert TypeTalk.Util.make_indexed_params("hoge", [1,2,3]) == [{:"hoge[0]", 1}, {:"hoge[1]", 2}, {:"hoge[2]", 3}]
  end
end
