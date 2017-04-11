defmodule TypeTalk.AuthlTest do
  use ExUnit.Case

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  test "header for binary" do
    assert {"X-Typetalk-Token", "hoge"} == TypeTalk.Auth.header("hoge")
  end

  test "header for map" do
    assert {"Authorization", "Bearer hoge"} == TypeTalk.Auth.header(%{"access_token" => "hoge"})
  end
end
