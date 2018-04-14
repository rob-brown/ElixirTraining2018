defmodule Swapi.MixProject do
  use Mix.Project

  def project do
    [
      app: :swapi,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      mod: {Swapi.Application, []}
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.4.10"},
      {:absinthe_plug, "~> 1.4.2"},
      {:cowboy, "~> 2.3.0"},
      {:plug, "~> 1.5.0"},
      {:poison, "~> 3.1.0"},
      {:httpoison, "~> 1.1.0"}
    ]
  end
end
