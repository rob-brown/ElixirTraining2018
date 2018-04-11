defmodule Proc.Server do
  @enforce_keys [:port, :buffer, :clients]
  defstruct [:port, :buffer, :clients]

  use GenServer
  alias Proc.TLV
  require Proc.TLV.Constant, as: Constant
  require Logger

  def start_link() do
    GenServer.start_link __MODULE__, []
  end

  def init(_args) do
    with port = start_process(),
        state = %__MODULE__{port: port, buffer: <<>>, clients: []} do
      {:ok, state}
    end
  end

  def handle_cast({:push, value}, state) do
    transmit state.port, [{Constant.push, value}]
    {:noreply, state}
  end
  def handle_cast(:pop, state) do
    transmit state.port, [Constant.pop]
    {:noreply, state}
  end
  def handle_cast(:clear, state) do
    transmit state.port, [Constant.clear]
    {:noreply, state}
  end

  def handle_call(:peek, from, state) do
    transmit state.port, [Constant.peek]
    new_state = %__MODULE__{state | clients: state.clients ++ [from]}
    {:noreply, new_state}
  end
  def handle_call(:count, from, state) do
    transmit state.port, [Constant.count]
    new_state = %__MODULE__{state | clients: state.clients ++ [from]}
    {:noreply, new_state}
  end

  def handle_info({_port, {:data, data}}, state) do
    with buffer = state.buffer <> data,
        {tlvs, new_buffer} = TLV.parse(buffer),
        new_state = %__MODULE__{state | buffer: new_buffer} |> handle_tlvs(tlvs) do
      {:noreply, new_state}
    end
  end
  def handle_info({_port, {:exit_status, 0}}, state) do
    Logger.debug "Stack exited normally"
    {:stop, :normal, state}
  end
  def handle_info({_port, {:exit_status, status}}, state) do
    Logger.error "Stack exited abnormally #{status}"
    {:stop, status, state}
  end
  def handle_info(message, state) do
    Logger.warn "Unhandled message: #{inspect message}"
    {:noreply, state}
  end

  defp start_process() do
    Logger.debug "Starting stack process"
    Port.open {:spawn_executable, command()}, options()
  end

  defp command do
    with priv = :code.priv_dir(:proc),
      exec = "stack"
    do
      Path.join priv, exec
    end
  end

  defp options do
    [:use_stdio, :exit_status, :binary, :hide, :stream, args: []]
  end

  defp transmit(port, tlvs) do
    tlvs
    |> TLV.build
    |> (& Port.command port, &1).()
  end

  defp handle_tlvs(state, []) do
    state
  end
  defp handle_tlvs(state = %__MODULE__{clients: [client | other_clients]}, [{Constant.item, value} | other_tlvs]) do
    with _ = GenServer.reply(client, {:ok, value}),
        new_state = %__MODULE__{state | clients: other_clients} do
      handle_tlvs(new_state, other_tlvs)
    end
  end
  defp handle_tlvs(state = %__MODULE__{clients: [client | other_clients]}, [{Constant.error, error} | other_tlvs]) do
    with _ = GenServer.reply(client, {:error, error}),
        new_state = %__MODULE__{state | clients: other_clients} do
      handle_tlvs(new_state, other_tlvs)
    end
  end
  defp handle_tlvs(state, [{Constant.error, error} | rest]) do
    Logger.error "C reported error: #{inspect error}"
    handle_tlvs state, rest
  end
  defp handle_tlvs(state, [{Constant.log, log} | rest]) do
    Logger.debug "Received log #{inspect log}"
    handle_tlvs state, rest
  end
  defp handle_tlvs(state, [tlv | rest]) do
    Logger.warn "Unhandled TLV: #{inspect tlv}"
    handle_tlvs state, rest
  end
end
