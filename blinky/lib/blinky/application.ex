defmodule Blinky.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Blinky
    ]

    opts = [strategy: :one_for_one, name: Blinky.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
