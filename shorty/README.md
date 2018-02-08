# Shorty

A URL shortener demo.

## Usage

### In Memory Registry

1. Modify `Shorty.Server` to use `alias Shorty.Registry.InMemory, as: Registry`
2. Start with `PORT=8000 iex -S mix`
3. Shorten URL with POST to `http://localhost:8000/shorten` with URL in the body. That returns a shortened URL.
4. Expand URL with GET to returned URL.

### Postgres (Ecto) Registry

1. Modify `Shorty.Server` to use `alias Shorty.Registry.Ecto, as: Registry`
2. Install Postgres (ex. [Postgres.app](http://postgresapp.com))
3. Run `mix ecto.create`
4. Run `mix ecto.migrate`
5. Start with `PORT=8000 iex -S mix`
6. Shorten URL with POST to `http://localhost:8000/shorten` with URL in the body.
7. Expand URL with GET to returned URL.
