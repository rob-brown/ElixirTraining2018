defmodule ShortyTest do
  use ExUnit.Case
  doctest Shorty

  test "greets the world" do
    assert Shorty.hello() == :world
  end
end
