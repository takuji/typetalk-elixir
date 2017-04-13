defmodule TypetalkTokenTest do
  use ExUnit.Case

  @token System.get_env("TYPETALK_TOKEN")
  @topic_id System.get_env("TYPETALK_TOPIC_ID")

  test "typetalk token usage" do
    {:ok, res} = Typetalk.post_message(@token, @topic_id, "hey")
    assert res["post"] != nil
  end
end
