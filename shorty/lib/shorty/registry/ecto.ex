defmodule Shorty.Registry.Ecto do
  defstruct []

  alias Shorty.{Mapping, Repo, IdGenerator}

  def shorten(registry, url) do
    with nil <- Repo.get_by(Mapping, url: url),
         key = generate_id(),
         {:ok, _} <- %Mapping{} |> Mapping.changeset(%{key: key, url: url}) |> Repo.insert() do
      {:ok, registry, key}
    else
      %Mapping{key: key} ->
        {:ok, registry, key}

      other ->
        other
    end
  end

  def lookup(_, key) do
    case Repo.get_by(Mapping, key: key) do
      nil ->
        :error

      result ->
        {:ok, result.url}
    end
  end

  defp generate_id do
    with id = IdGenerator.generate() do
      case Repo.get_by(Mapping, key: id) do
        nil ->
          id

        _ ->
          generate_id()
      end
    end
  end
end

defimpl Shorty.Registry, for: Shorty.Registry.Ecto do
  def shorten(registry, url), do: @for.shorten(registry, url)
  def lookup(registry, id), do: @for.lookup(registry, id)
end
