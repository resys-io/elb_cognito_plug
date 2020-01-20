defmodule ELBCognitoPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :elb_cognito_plug,
      name: "ELB Cognito Plug",
      description: "Verifies AWS Cognito JWTs passed in by AWS ELB",
      package: %{
        files: [
          "lib",
          "mix.exs",
          "LICENSE"
        ],
        licenses: ["MIT"]
      },
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.8.3"},
      {:joken, "~> 2.2"},
      {:tesla, "~> 1.2.1"}
    ]
  end
end
