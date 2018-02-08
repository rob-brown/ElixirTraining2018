defmodule Shorty.Mapping do
  use Ecto.Schema

  schema "mapping" do
    field(:key, :string)
    field(:url, :string)
  end

  def changeset(mapping, params \\ %{}) do
    mapping
    |> Ecto.Changeset.cast(params, [:key, :url])
    |> Ecto.Changeset.validate_required([:key, :url])
  end
end
