defmodule Swapi.Router do
  use Plug.Router
  require Logger

  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  ## Routes

  forward(
    "/api",
    to: Absinthe.Plug,
    init_opts: [
      schema: Swapi.Schema,
      analyze_complexity: true,
      max_complexity: 50
    ]
  )

  forward(
    "/graphiql",
    to: Absinthe.Plug.GraphiQL,
    init_opts: [
      schema: Swapi.Schema,
      interface: :simple,
      #analyze_complexity: true,
      #max_complexity: 50
    ]
  )
end
