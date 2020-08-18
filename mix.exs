defmodule Typetalk.Mixfile do
  use Mix.Project

  @description """
  Typetalk API client for Elixir
  """

  def project do
    [app: :typetalk,
     version: "0.1.2",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "Typetalk",
     description: @description,
     package: package(),
     deps: deps()]
  end

  def application do
    []
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:httpoison, "~> 1.7.0"},
      {:poison, "~> 4.0"},
      {:socket, "~> 0.3.13"},
      {:ex_doc, "~> 0.19.1", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Takuji Shimokawa"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/takuji/typetalk-elixir"}
    ]
  end
end
