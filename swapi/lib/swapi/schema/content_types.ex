defmodule Swapi.Schema.ContentTypes do
  use Absinthe.Schema.Notation
  alias Swapi.Resolvers

  object :planet do
    field(:name, :string)
    field(:population, :string)
    field :residents, list_of(:person) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve &Resolvers.Content.list_people/3
    end
    field(:films, list_of(:film)) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve &Resolvers.Content.list_films/3
    end
  end

  object :person do
    field(:name, :string)
    field(:films, list_of(:film))
    field(:homeworld, :planet) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve &Resolvers.Content.list_planets/3
    end
  end

  object :film do
    field(:title, :string)
    field(:opening_crawl, :string)
    field(:episode_id, :integer)
    field(:characters, list_of(:person)) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve &Resolvers.Content.list_people/3
    end
    field(:planets, list_of(:planet)) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve &Resolvers.Content.list_planets/3
    end
  end
end
