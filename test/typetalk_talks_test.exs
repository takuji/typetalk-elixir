defmodule TypetalkTalksTest do
  use ExUnit.Case
  import TypetalkTestHelper

  test "get talks" do
    auth = access_token()
    topic = get_topic(auth)
    {:ok, res} = Typetalk.get_talks(auth, topic["id"])
    assert res["talks"] != nil
  end

  test "create talk" do
    auth = access_token(scope: "my,topic.post,topic.write,topic.delete")
    topic = get_topic(auth)
    {:ok, post1} = Typetalk.post_message(auth, topic["id"], "その１")
    {:ok, post2} = Typetalk.post_message(auth, topic["id"], "その２")
    {:ok, post3} = Typetalk.post_message(auth, topic["id"], "その３")
    postIds = [post1["post"]["id"], post2["post"]["id"], post3["post"]["id"]]
    {:ok, res} = Typetalk.create_talk(auth, topic["id"], "Talk-#{:os.system_time(:millisecond)}", postIds)
    assert res["talk"] != nil
    assert res["postIds"] == postIds

    {:ok, _} = Typetalk.delete_talk(auth, topic["id"], res["talk"]["id"])
  end

  def create_talk(auth, topic) do
    {:ok, post1} = Typetalk.post_message(auth, topic["id"], "その１")
    {:ok, post2} = Typetalk.post_message(auth, topic["id"], "その２")
    {:ok, post3} = Typetalk.post_message(auth, topic["id"], "その３")
    postIds = [post1["post"]["id"], post2["post"]["id"], post3["post"]["id"]]
    Typetalk.create_talk(auth, topic["id"], "Talk-#{:os.system_time(:millisecond)}", postIds)
  end

  test "get talk posts" do
    auth = access_token(scope: "my,topic.read,topic.post,topic.write,topic.delete")
    topic = get_topic(auth)
    {:ok, talk} = create_talk(auth, topic)
    {:ok, res} = Typetalk.get_talk_messages(auth, topic["id"], talk["talk"]["id"])
    assert res["posts"] != nil
  end

  test "update talk" do
    auth = access_token(scope: "my,topic.post,topic.write,topic.delete")
    topic = get_topic(auth)
    {:ok, talk} = create_talk(auth, topic)
    new_name = "新しい名前"
    {:ok, res} = Typetalk.update_talk(auth, talk["topic"]["id"], talk["talk"]["id"], new_name)
    assert res["talk"]["name"] == new_name

    {:ok, _} = Typetalk.delete_talk(auth, talk["topic"]["id"], talk["talk"]["id"])
  end

  test "add post to talk" do
    auth = access_token(scope: "my,topic.post,topic.write,topic.delete")
    topic = get_topic(auth)
    {:ok, talk} = create_talk(auth, topic)
    message = "New message #{:os.system_time(:millisecond)}"
    {:ok, post} = Typetalk.post_message(auth, talk["topic"]["id"], message)
    postIds = [post["post"]["id"]]
    {:ok, res} = Typetalk.add_messages_to_talk(auth, talk["topic"]["id"], talk["talk"]["id"], postIds)
    assert res["postIds"] != nil

    {:ok, _} = Typetalk.delete_talk(auth, talk["topic"]["id"], talk["talk"]["id"])    
  end
end
