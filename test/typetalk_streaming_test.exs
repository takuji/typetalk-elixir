defmodule TypeTalkStreamingTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "streaing" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, socket} = TypeTalk.Streaming.connect(auth)
    t = Task.async(fn -> TypeTalk.Streaming.listen(socket) end)
    # Send a message
    message = "Streeeeeeeeeeeeeeem! #{:os.system_time(:millisecond)}"
    spawn(fn -> TypeTalk.create_topic_post(auth, topic["id"], message) end)
    # Start to wait a message from the server
    {:message, msg} = Task.await(t, 2000)
    assert msg["data"]["post"]["message"] == message
    TypeTalk.Streaming.close(socket)
  end
end
