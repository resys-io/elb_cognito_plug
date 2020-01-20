# ELBCognitoPlug

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elb_cognito_plug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elb_cognito_plug, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/elb_cognito_plug](https://hexdocs.pm/elb_cognito_plug).

## Usage
```elixir
plug ELBCognitoPlug,
  region: Application.get_env(:my_app, :cognito_region),
  pool_id: Application.get_env(:my_app, :cognito_pool_id),
  require_header: false,
  has_group: "oprh.admin"
```
