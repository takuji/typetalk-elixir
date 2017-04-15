# Typetalk API client for Elixir

A Typetalk client library for Elixir language.

API Document: https://hexdocs.pm/typetalk/api-reference.html

## Installation

This package can be installed by adding `typetalk` to your list of dependencies in `mix.exs`:

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

Take the user to the authorization page.
```elixir
client_id = System.get_env("TYPETALK_CLIENT_ID")
redirect_url = "https://example.com/oauth_callback"
scope = "my,topic.read,topic.post"
url = Typetalk.AuthorizationCode.authorization_url(client_id, redirect_url, scope)
```

Use the published authorization token (`auth_code` in the example below) to get an access token.
```elixir
client_id = System.get_env("TYPETALK_CLIENT_ID")
client_secret = System.get_env("TYPETALK_CLIENT_SECRET")
{:ok, access_token} = Typetalk.AuthorizationCode.access_token(client_id, client_secret, auth_code)
{:ok, spaces} = Typetalk.get_spaces(access_token)
```
