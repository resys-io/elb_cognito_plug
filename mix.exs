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
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ELBCognitoPlug.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.8"},
      {:joken, "~> 2.2"},
      {:tesla, "~> 1.2"},
      {:jason, "~> 1.1"}
    ]
  end
end
