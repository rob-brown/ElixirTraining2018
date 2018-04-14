defmodule Swapi.Schema do
  use Absinthe.Schema
  import_types(Swapi.Schema.ContentTypes)
  alias Swapi.Resolvers

  query do
    field :planets, list_of(:planet) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve(&Resolvers.Content.list_planets/3)
    end

    field :planets_with_name, list_of(:planet) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      arg :name, non_null(:string)
      resolve(&Resolvers.Content.search_planets/3)
    end

    field :people, list_of(:person) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve(&Resolvers.Content.list_people/3)
    end

    field :films, list_of(:film) do
      arg :limit, :integer, default_value: 10
      arg :skip, :integer, default_value: 0
      resolve(&Resolvers.Content.list_films/3)
    end
  end
end
