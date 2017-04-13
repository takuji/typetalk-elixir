defmodule Typetalk.Mixfile do
  use Mix.Project

  @description """
  Typetalk API client for Elixir
  """

  def project do
    [app: :typetalk,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "Typetalk",
     description: @description,
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.1"},
      {:socket, "~> 0.3"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp package do
    [ files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Takuji Shimokawa"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/takuji/typetalk-elixir"}
    ]
  end
end
