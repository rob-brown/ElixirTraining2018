defmodule Shorty.Registry.InMemory do
  defstruct mappings: %{}, reverse_mapppings: %{}

  alias Shorty.IdGenerator

  def shorten(r = %__MODULE__{mappings: mappings, reverse_mapppings: reverse}, url) do
    with nil <- Map.get(reverse, url),
         id = generate_id(mappings),
         new_mappings = Map.put(mappings, id, url),
         new_reverse = Map.put(reverse, url, id),
         new_registry = %__MODULE__{r | mappings: new_mappings, reverse_mapppings: new_reverse} do
      {:ok, new_registry, id}
    else
      id when is_binary(id) ->
        {:ok, r, id}

      other ->
        other
    end
  end

  def lookup(%__MODULE__{mappings: mappings}, id) do
    Map.fetch(mappings, id)
  end

  defp generate_id(mappings) do
    with id = IdGenerator.generate() do
      if Map.get(mappings, id) do
        generate_id(mappings)
      else
        id
      end
    end
  end
end

defimpl Shorty.Registry, for: Shorty.Registry.InMemory do
  def shorten(registry, url), do: @for.shorten(registry, url)
  def lookup(registry, id), do: @for.lookup(registry, id)
end
