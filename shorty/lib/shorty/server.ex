defmodule Shorty.Server do
  use GenServer
  alias Shorty.Registry.InMemory, as: Registry
  # alias Shorty.Registry.Ecto, as: Registry

  def start_link(_) do
    GenServer.start_link(__MODULE__, %Registry{}, name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def handle_call({:shorten, url}, _from, state) do
    {:ok, new_state, response} = Shorty.Registry.shorten(state, url)
    {:reply, response, new_state}
  end

  def handle_call({:lookup, id}, _from, state) do
    response = Shorty.Registry.lookup(state, id)
    {:reply, response, state}
  end
end
