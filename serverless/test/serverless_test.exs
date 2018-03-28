defmodule ServerlessTest do
  use ExUnit.Case
  doctest Serverless

  test "greets the world" do
    assert Serverless.hello() == :world
  end
end
