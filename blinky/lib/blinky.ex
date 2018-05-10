defmodule Blinky do
  alias Nerves.Leds

  require Logger

  def start_link() do
    Logger.debug "Starting Blinky"
    Leds.set green: :heartbeat
    {:ok, self()}
  end

  def child_spec do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
    }
  end
end
