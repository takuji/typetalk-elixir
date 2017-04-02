defmodule TypeTalk.Util do
  @moduledoc """
  Utility functions for implementing APIs.
  """
  def auth_header(auth) do
    %{"Authorization" => "Bearer #{auth["access_token"]}"}
  end
end