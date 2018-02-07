defmodule Shorty.Registry do
  def new, do: %{}

  def shorten(registry, url) do
    with id = generate_id(registry), new_registry = Map.put(registry, id, url) do
      {new_registry, id}
    end
  end

  def lookup(registry, id) do
    Map.fetch(registry, id)
  end

  defp generate_id(registry) do
    with alphabet = Enum.flat_map([?a..?z, ?A..?Z, ?0..?9], & &1),
         id = 1..6 |> Enum.map(fn _ -> Enum.random(alphabet) end) |> to_string do
      if Map.get(registry, id) do
        generate_id(registry)
      else
        id
      end
    end
  end
end
