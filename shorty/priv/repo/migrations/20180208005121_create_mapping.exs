defmodule Shorty.Repo.Migrations.CreateMapping do
  use Ecto.Migration

  def change do
    create table(:mapping) do
      add :key, :string, null: false
      add :url, :string, null: false
    end
  end
end
