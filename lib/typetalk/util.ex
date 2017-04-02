defmodule TypeTalk.Util do
  @moduledoc """
  Utility functions for implementing APIs.
  """
  def auth_header(auth) do
    %{"Authorization" => "Bearer #{auth["access_token"]}"}
  end

  def handle_response({:ok, res}) do
    case res.status_code do
      200 -> Poison.decode(res.body)
      _ -> {:error, res}
    end
  end

  def handle_response({_, err}) do
    {:error, err}
  end
end