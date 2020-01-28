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
### Configuration
You can configure the plug either through configuration or plug options:

```elixir
config :elb_cognito_plug,
  cognito_region: "eu-central-1",
  cognito_pool_id: "eu-central-1_gbM12ad3"
```

```elixir
plug ELBCognitoPlug,
  cognito_region: "eu-central-1",
  cognito_pool_id: "eu-central-1_gbM12ad3",
  require_header: false,
  has_group: "admin",
  assign_to: :user_info,
  keys_module: MyKeyModule
```

The options used through configuration are always evaluated at run-time. Options provided through
the plug are evaluated depending on the `:init_mode` used in [`Plug.Builder`](https://hexdocs.pm/plug/Plug.Builder.html).
If an option is defined in both places, the option provided through the plug will take precedence
over the one in configuration.

### Options
- `:cognito_region` - **required** Cognito region
- `:cognito_pool_id` - **required** Cognito pool id
- `:require_header` - if set to `true`, request will be denied if no ELB headers are present.
Defaults to `true`.
- `:has_group` - requires the user to have the given group, otherwise the request will be denied
- `:assign_to` - assigns the decoded JWT data to the given atom
- `:keys_module` - allows you to define custom key-fetching behaviour. Default behaviour pulls key
from AWS with Tesla and caches them in ETS. See `ELBCognitoPlug.Cognito.Keys` and 
`ELBCognitoPlug.Cognito.TeslaCachedKeys`
