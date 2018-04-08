defmodule ServerWeb.FridgeChannel do

  use Phoenix.Channel
  require Logger
  alias Model.{Server, Magnet}

  def join("fridge:" <> id, _message, socket) do
    with new_socket = assign(socket, :fridge_id, id),
         _ <- Server.start_link(id) do
      {:ok, new_socket}
    end
  end

  # ???: Should I have a message for showing where the other cursors are?

  def handle_in(event = "state", _, socket) do
    with fridge = socket.assigns[:fridge_id],
         state = Server.state(fridge) do
      push socket, event, state
    end
  end

  def handle_in(event = "add_word", %{"word" => word, "x" => x, "y" => y}, socket) do
    with id = make_ref() |> :erlang.term_to_binary |> Base.encode16,
         magnet = Magnet.new(id, word, x, y),
         fridge = socket.assigns[:fridge_id],
         :ok <- Server.add_magnet(fridge, magnet),
         _ = broadcast!(socket, event, magnet) do
      {:noreply, socket}
    end
  end
  def handle_in(event, payload, socket) do
    _ = Logger.error "Unhandled event: #{inspect event} with payload: #{inspect payload}"
    {:noreply, socket}
  end
end
