defmodule TypeTalkTest do
  use ExUnit.Case
  doctest TypeTalk

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  defp access_token() do
    {:ok, json} = TypeTalk.access_token(client_id: @client_id, client_secret: @client_secret)
    json    
  end

  defp account() do
  end

  test "access_token" do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret
    )
    assert json["access_token"] != nil
  end

  test "profile" do
    token = access_token()
    {:ok, profile} = TypeTalk.profile(token)
    assert profile["account"] != nil
  end

  test "account profile" do
    token = access_token()
    {:ok, profile} = TypeTalk.account_profile(token, "shimokawa")
    assert profile["account"] != nil    
  end

  test "account status" do
    # token = access_token()
    # {:ok, profile} = TypeTalk.account_profile(token, "shimokawa")
    # {:ok, json} = TypeTalk.accounts_status(token, [profile["account"]["id"]])
    # assert json["accounts"] != nil    
  end

  test "topics" do
    token = access_token()
    {:ok, res} = TypeTalk.topics(token)
    assert res["topics"] != nil
  end
end
