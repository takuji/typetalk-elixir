defmodule TypeTalkTest do
  use ExUnit.Case
  doctest TypeTalk

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "access_token" do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret
    )
    assert json["access_token"] != nil
  end
end
