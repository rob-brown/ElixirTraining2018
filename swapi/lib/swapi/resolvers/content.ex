defmodule Swapi.Resolvers.Content do
  alias Swapi.HTTP
  require Logger

  def search_planets(_parent, args = %{name: name}, _resolution) do
    request_all "https://swapi.co/api/planets?search=#{name}", args
  end

  def list_planets(%{planets: planets}, args, _resolution) do
    request_each [planets], args
  end

  def list_planets(%{homeworld: homeworld}, args, _resolution) do
    request_each [homeworld], args
  end

  def list_planets(_parent, args, _resolution) do
    request_all "https://swapi.co/api/planets", args
  end

  def list_people(%{characters: characters}, args, _resolution) do
    request_each characters, args
  end

  def list_people(%{residents: residents}, args, _resolution) do
    request_each residents, args
  end

  def list_people(_parent, args, _resolution) do
    request_all "https://swapi.co/api/people", args
  end

  def list_films(%{films: films}, args, _resolution) do
    request_each films, args
  end

  def list_films(_parent, args, _resolution) do
    request_all "https://swapi.co/api/films", args
  end

  # Helpers

  defp request_all(url, args) do
    with limit = Map.get(args, :limit, 10),
         skip = Map.get(args, :skip, 0) do
      url
      |> HTTP.get_stream()
      |> Stream.drop(skip)
      |> Stream.take(limit)
      |> Stream.map(&atomify/1)
      |> Enum.to_list()
      |> (&{:ok, &1}).()
    end
  end

  defp request_each(urls, args) do
    with limit = Map.get(args, :limit, 10),
         skip = Map.get(args, :skip, 0) do
      urls
      |> Stream.drop(skip)
      |> Stream.take(limit)
      |> Stream.map(&HTTP.get/1)
      |> Stream.reject(&is_nil/1)
      |> Stream.map(&Poison.decode!/1)
      |> Stream.map(&atomify/1)
      |> Enum.to_list
      |> (&{:ok, &1}).()
    end
  end

  defp atomify(map = %{}) do
    map 
    |> Stream.map(fn {k, v} -> {String.to_atom(k), v} end) 
    |> Enum.into(%{})
  end
end
