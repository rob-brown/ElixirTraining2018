defmodule Serverless.FunctionRepo do
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [:ok]}
    }
  end

  def add(fun) when is_function(fun) do
    Agent.get_and_update(__MODULE__, fn state ->
      id = make_ref()
      new_map = Map.put(state, id, fun)
      {id, new_map}
    end)
  end

  def get(id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, id)
    end)
  end
end
