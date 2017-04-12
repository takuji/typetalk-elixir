defmodule Typetalk.AuthlTest do
  use ExUnit.Case

  test "header for binary" do
    assert {"X-Typetalk-Token", "hoge"} == Typetalk.Auth.header("hoge")
  end

  test "header for AccessToken" do
    assert {"Authorization", "Bearer hoge"} == Typetalk.Auth.header(%Typetalk.AccessToken{access_token: "hoge"})
  end
end
