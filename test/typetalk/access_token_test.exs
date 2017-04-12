defmodule Typetalk.AccessTokenTest do
  use ExUnit.Case

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  test "refresh_access_token" do
    {:ok, access_token} = Typetalk.ClientCredential.access_token(@client_id, @client_secret)
    {:ok, access_token2} = Typetalk.AccessToken.refresh(access_token, @client_id, @client_secret)
    assert access_token2.access_token != nil
    assert access_token2.token_type == "Bearer"
    assert access_token2.expires_in > 3500
    assert access_token2.expires_in <= 3600
    assert access_token2.refresh_token != nil
  end
end
