defmodule Model.WordList do

  @enforce_keys [:name, :words]
  defstruct [:name, :words]

  def new(name, words) do
    %__MODULE__{name: name, words: words}
  end

  def random_word(%__MODULE__{words: words}) do
    Enum.random(words)
  end
end
