defmodule ProcTest do
  use ExUnit.Case
  doctest Proc

  test "greets the world" do
    assert Proc.hello() == :world
  end
end
