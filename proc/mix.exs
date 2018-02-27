defmodule Proc.MixProject do
  use Mix.Project

  def project do
    [
      app: :proc,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers,
      deps: deps()
    ] ++ make_options()
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp make_options do
    [
      make_makefile: "Makefile",
      make_targets: ["all"],
      make_clean: ["clean"],
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4.1", runtime: false},
    ]
  end
end
