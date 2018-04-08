defmodule Model.Server do

  alias Model.{Fridge, Magnet}

  def start_link(name) do
    Agent.start_link fn -> Fridge.new(500, 500) end, name: server_name(name)
  end

  def state(name) do
    Agent.get server_name(name), (& &1)
  end

  def add_magnet(name, magnet = %Magnet{}) do
    Agent.update server_name(name), fn state ->
      Fridge.add_magnet state, magnet
    end
  end

  defp server_name(name) do
    :"#{__MODULE__}.#{name}"
  end
end
