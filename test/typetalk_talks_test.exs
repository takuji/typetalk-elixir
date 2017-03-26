defmodule TypeTalkTest do
  use ExUnit.Case
  import TypeTalkTestHelper

  test "get talks" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = TypeTalk.talks(auth, topic["id"])
    assert res["talks"] != nil
  end

  test "create talk" do
    auth = access_token(scope: "my,topic.post,topic.write")
    topic = get_topic(auth)
    {:ok, post1} = TypeTalk.create_topic_post(auth, topic["id"], "その１")
    {:ok, post2} = TypeTalk.create_topic_post(auth, topic["id"], "その２")
    {:ok, post3} = TypeTalk.create_topic_post(auth, topic["id"], "その３")
    postIds = [post1["post"]["id"], post2["post"]["id"], post3["post"]["id"]]
    {:ok, res} = TypeTalk.create_talk(auth, topic["id"], "Talk-#{:os.system_time(:millisecond)}", postIds)
    assert res["talk"] != nil
  end

  test "get talk posts" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = TypeTalk.talks(auth, topic["id"])
    talk = Enum.at(res["talks"], 0)
    {:ok, res} = TypeTalk.talk_posts(auth, topic["id"], talk["id"])
    assert res["posts"] != nil
  end  
end
