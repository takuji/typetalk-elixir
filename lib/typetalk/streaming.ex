defmodule Typetalk.Streaming do
  @moduledoc """
  Functions for streaming
  """
  import Typetalk.Util

  def connect(token) do
    Socket.Web.connect("message.typetalk.com", path: "/api/v1/streaming", secure: true, headers: auth_header(token))
  end

  def close(socket) do
    Socket.Web.close(socket)
  end

  def read(socket) do
    case Socket.Web.recv(socket) do
      {:ok, {:text, text}} ->
        case Poison.decode(text) do
          {:ok, json} -> {:message, json}
          {_, error} -> {:error, error}
        end
      {:ok, {:ping, _}} ->
        Socket.Web.send!(socket, {:pong, ""})
        read(socket)
      {_, res} ->
        {:error, res}
    end
  end
end
