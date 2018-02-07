defmodule Shorty.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = System.get_env("PORT") |> String.to_integer()

    children = [
      Shorty.Server,
      Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Shorty.Router, options: [port: port])
    ]

    opts = [strategy: :one_for_one, name: Shorty.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
