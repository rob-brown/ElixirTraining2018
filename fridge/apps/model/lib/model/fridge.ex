defmodule Model.Fridge do

  @enforce_keys [:x_size, :y_size, :magnets]
  defstruct [:x_size, :y_size, :magnets]

  alias Model.Magnet

  def new(x_size, y_size, magnets \\ []) do
    %__MODULE__{x_size: x_size, y_size: y_size, magnets: magnets}
  end

  def add_magnet(fridge = %__MODULE__{}, magnet = %Magnet{}) do
    %__MODULE__{fridge | magnets: [magnet | fridge.magnets]}
  end
end
