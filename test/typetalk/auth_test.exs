defmodule Typetalk.AuthlTest do
  use ExUnit.Case

  test "header for binary" do
    assert {"X-Typetalk-Token", "hoge"} == Typetalk.Auth.header("hoge")
  end

  test "header for map" do
    assert {"Authorization", "Bearer hoge"} == Typetalk.Auth.header(%{"access_token" => "hoge"})
  end
end
