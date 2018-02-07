defmodule Shorty do
  @server_name Shorty.Server

  def shorten(server \\ @server_name, url) do
    GenServer.call(server, {:shorten, url})
  end

  def lookup(server \\ @server_name, url) do
    GenServer.call(server, {:lookup, url})
  end
end
