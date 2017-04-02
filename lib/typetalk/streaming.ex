defmodule TypeTalk.Streaming do
  @moduledoc """
  Functions for streaming
  """
  import TypeTalk.Util

  def connect(auth) do
    Socket.Web.connect("typetalk.in", path: "/api/v1/streaming", secure: true, headers: auth_header(auth))
  end

  def close(socket) do
    Socket.Web.close(socket)
  end

  def listen(socket) do
    case Socket.Web.recv(socket) do
      {:ok, {:text, text}} ->
        case Poison.decode(text) do
          {:ok, json} -> {:message, json}
          {_, error} -> {:error, error}
        end
      {:ok, {:ping, _}} ->
        Socket.Web.send!(socket, {:pong, ""})
        listen(socket)
      {_, res} ->
        {:error, res}
    end
  end
end
