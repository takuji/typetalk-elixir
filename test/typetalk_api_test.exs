defmodule TypeTalkTest do
  use ExUnit.Case
  doctest TypeTalk

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "access_token" do
    {:ok, json} = TypeTalk.access_token(
      client_id: "your client id",
      client_secret: "your client secret",
    )
    IO.inspect json
    assert json["access_token"] != nil
  end
end
