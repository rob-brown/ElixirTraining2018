defmodule Server.Mixfile do
  use Mix.Project

  def project do
    [
      app: :server,
      version: "0.1.0",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext, :elixir_make] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
   ] ++ make_options()
  end

  def application do
    [
      mod: {Server.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp make_options do
    [
      make_makefile: "Makefile",
      make_targets: ["all"],
      make_clean: ["clean"],
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:model, path: "../model"},
      {:elixir_make, "~> 0.4", runtime: false}
    ]
  end
end
