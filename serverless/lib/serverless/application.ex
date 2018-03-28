defmodule Serverless.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = System.get_env("PORT") |> String.to_integer()

    children = [
      {Plug.Adapters.Cowboy2, scheme: :http, plug: Serverless.Router, options: [port: port]},
      Serverless.FunctionRepo
    ]

    opts = [strategy: :one_for_one, name: Serverless.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
