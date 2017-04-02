defmodule TypeTalkAttachmentsTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "upload attachment" do
    auth = access_token()
    topic = get_topic(auth)
    topic_id = topic["id"]
    filepath = "test/data/a.txt"
    {:ok, res} = TypeTalk.upload_attachment(auth, topic_id, filepath)
    assert res["fileKey"] != nil
  end
end
