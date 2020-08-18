defmodule Typetalk.Server do
  @moduledoc """
  Typetalk API Server 
  """
  use GenServer

  #
  # Client APIs
  #

  def start_link(auth) do
    GenServer.start_link(__MODULE__, auth)
  end

  def call(pid, api, args \\ []) do
    GenServer.call(pid, {api, args})
  end

  #
  # OTP callbacks
  #
  def init(args) do
    {:ok, args}
  end

  def handle_call({api, args}, _from, auth) do
    result = apply(Typetalk, api, [auth | args])
    {:reply, result, auth}
  end
end
