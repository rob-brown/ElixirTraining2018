defmodule Shorty.MixProject do
  use Mix.Project

  def project do
    [
      app: :shorty,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Shorty.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.5.0-rc.1"},
      {:cowboy, "~> 2.2.2"},
      {:ecto, "~> 2.2.8"},
      {:postgrex, "~> 0.13.0"}
    ]
  end
end
