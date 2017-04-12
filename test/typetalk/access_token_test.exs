defmodule Typetalk.AccessTokenTest do
  use ExUnit.Case

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  test "refresh_access_token" do
    {:ok, auth} = Typetalk.ClientCredential.access_token(@client_id, @client_secret)
    {:ok, auth2} = Typetalk.AccessToken.refresh(@client_id, @client_secret, auth)
    assert auth2.access_token != nil
  end
end
