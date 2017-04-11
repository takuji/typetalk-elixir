defmodule Typetalk.ClientCrendentialTest do
  use ExUnit.Case

  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  test "access_token" do
    {:ok, json} = Typetalk.ClientCredential.access_token(
      @client_id,
      @client_secret
    )
    assert json["access_token"] != nil
  end
end
