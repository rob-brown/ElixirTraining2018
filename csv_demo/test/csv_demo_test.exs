defmodule CsvDemoTest do
  use ExUnit.Case
  doctest CsvDemo

  test "greets the world" do
    assert CsvDemo.hello() == :world
  end
end
