defmodule Proc.TLV.Constant do

  info = %{
    push: 1,
    pop: 2,
    peek: 3,
    clear: 4,
    count: 5,
    item: 6,
    error: 7,
    log: 8,
  }

  for {name, value} <- info do
    defmacro unquote(name)(), do: unquote(value)
  end
end
