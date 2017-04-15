defmodule Typetalk.Util do
  @moduledoc """
  Utility functions for implementing APIs.
  """
  def auth_header(auth) do
    {name, value} = Typetalk.Auth.header(auth)
    %{name => value}
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

  def make_indexed_params(name, values) do
    Enum.with_index(values)
    |> Enum.map(fn {value, idx} -> {:"#{name}[#{idx}]", value} end)
  end
end
