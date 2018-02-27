defmodule Proc do
  
  def start_link do
    Proc.Server.start_link
  end

  def push(stack, value) do
    GenServer.cast stack, {:push, value}
  end

  def pop(stack) do
    GenServer.cast stack, :pop
  end

  def peek(stack, timeout \\ 5000) do
    GenServer.call stack, :peek, timeout
  end

  def clear(stack) do
    GenServer.cast stack, :clear
  end

  def count(stack) do
    GenServer.call stack, :count
  end
end
