defmodule TypeTalkTestHelper do
  @client_id System.get_env("TYPETALK_CLIENT_ID")
  @client_secret System.get_env("TYPETALK_CLIENT_SECRET")

  def access_token(options \\ []) do
    {:ok, json} = TypeTalk.access_token(
      client_id: @client_id,
      client_secret: @client_secret,
      scope: Keyword.get(options, :scope, "my,topic.read,topic.post")
    )
    json    
  end
end

ExUnit.start()
