defmodule Shorty.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = System.get_env("PORT") |> String.to_integer()

    children = [
      Shorty.Server,
      Shorty.Repo,
      {Plug.Adapters.Cowboy2, scheme: :http, plug: Shorty.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: Shorty.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
