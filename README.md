# Typetalk API client for Elixir

A Typetalk client library for Elixir language.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `typetalk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:typetalk, "~> 0.1.0"}]
end
```

## Usage

### Using Typetalk token (Bot)

```elixir
token = System.get_env("TYPETALK_TOKEN")
topic_id = System.get_env("TYPETALK_TOPIC_ID")
{:ok, res} = Typetalk.post_message(token, topic_id, "hey")
```

### Using client credential

```elixir
client_id = System.get_env("TYPETALK_CLIENT_ID")
client_secret = System.get_env("TYPETALK_CLIENT_SECRET")
scope = "my,topic.read,topic.post"
{:ok, access_token} = Typetalk.ClientCredentail.access_token(client_id, client_secret, scope)
{:ok, spaces} = Typetalk.get_spaces(access_token)
```

### Using authorization code

```elixir
client_id = System.get_env("TYPETALK_CLIENT_ID")
client_secret = System.get_env("TYPETALK_CLIENT_SECRET")
scope = "my,topic.read,topic.post"
url = Typetalk.AuthorizationCode.authorization_url(client_id, client_secret, scope)
# Navigate the user to this URL to get an authorization code.

# auth_code is an authorization code the user has got at Typetalk's authorization page.
{:ok, access_token} = Typetalk.AuthorizationCode.access_token(client_id, client_secret, auth_code)
{:ok, spaces} = Typetalk.get_spaces(access_token)
```
