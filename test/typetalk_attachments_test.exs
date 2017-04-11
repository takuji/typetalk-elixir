defmodule TypetalkAttachmentsTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "upload attachment" do
    auth = access_token()
    topic = get_topic(auth)
    topic_id = topic["id"]
    filepath = "test/data/a.txt"
    {:ok, res} = Typetalk.upload_attachment(auth, topic_id, filepath)
    assert res["fileKey"] != nil
    {:ok, msg} = Typetalk.post_message(auth, topic_id, "Great attachment.", fileKeys: [res["fileKey"]])
    assert Enum.at(msg["post"]["attachments"],0)["attachment"]["fileKey"] == res["fileKey"]
  end
end
