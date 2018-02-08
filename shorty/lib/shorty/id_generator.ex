defmodule Shorty.IdGenerator do
  def generate(length \\ 6) when length > 0 do
    with alphabet = Enum.flat_map([?a..?z, ?A..?Z, ?0..?9], & &1),
         id = 1..length |> Enum.map(fn _ -> Enum.random(alphabet) end) |> to_string do
      id
    end
  end
end
