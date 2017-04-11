defprotocol Typetalk.Auth do
  @doc """
  Returns a HTTP header for authentication
  """
  @type auth :: map | binary

  @spec header(auth) :: {String.t, String.t}
  def header(auth)
end

defimpl Typetalk.Auth, for: BitString do
  def header(auth) do
    {"X-Typetalk-Token", auth}
  end
end

defimpl Typetalk.Auth, for: Map do
  def header(%{"access_token" => access_token}) do
    {"Authorization", "Bearer #{access_token}"}
  end
end
