# ELBCognitoPlug
This plug uses ELB authentication headers and verifies that the provided JWT was signed by Cognito.
Additionally, you can specify a group that is required to be present; otherwise the request is
denied.

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
  # Cognito region (required)
  region: Application.get_env(:my_app, :cognito_region),
  # Cognito pool id (required)
  pool_id: Application.get_env(:my_app, :cognito_pool_id),
  # If set to true, request will be denied if no ELB headers are present
  require_header: false,
  # Requires the user to have the given group, otherwise the request will be denied
  has_group: "admin",
  # Assigns the decoded JWT data to the given atom
  assign_to: :user_info
```
