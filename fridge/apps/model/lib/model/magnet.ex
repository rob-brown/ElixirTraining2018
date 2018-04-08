defmodule Model.Magnet do

  @enforce_keys [:id, :text, :x, :y]
  defstruct [:id, :text, :x, :y]

  def new(id, text, x, y) do
    %__MODULE__{id: id, text: text, x: x, y: y}
  end
end
