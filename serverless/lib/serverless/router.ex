defmodule Serverless.Router do
  use Plug.Router
  use Plug.ErrorHandler
  require Logger

  alias Serverless.FunctionRepo

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/add-function" do
    with %{"fun" => encoded} <- conn.params,
         {:ok, decoded} = Base.decode16(encoded),
         fun when is_function(fun) <- :erlang.binary_to_term(decoded),
         id = fun |> FunctionRepo.add() |> :erlang.term_to_binary() |> Base.encode16() do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(:ok, id)
    else
      error ->
        Logger.error("Error adding function: #{inspect(error)}")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:bad_request, "Bad request")
    end
  end

  get "/call/:function_id" do
    with {:ok, decoded} <- Base.decode16(function_id),
         ref when is_reference(ref) <- :erlang.binary_to_term(decoded),
         fun when is_function(fun) <- FunctionRepo.get(ref),
         {:ok, result} <- run_function(fun, conn.body_params) do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(:ok, to_string(result))
    else
      error ->
        Logger.error("Error calling function: #{inspect(error)}")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:bad_request, "Bad request")
    end
  end

  post "/call/:function_id" do
    with {:ok, decoded} <- Base.decode16(function_id),
         ref when is_reference(ref) <- :erlang.binary_to_term(decoded),
         fun when is_function(fun) <- FunctionRepo.get(ref),
         {:ok, result} <- run_function(fun, conn.params) do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(:ok, to_string(result))
    else
      error ->
        Logger.error("Error calling function: #{inspect(error)}")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:bad_request, "Bad request")
    end
  end

  match _ do
    conn
    |> send_resp(:not_found, "Not Found")
  end

  def handle_errors(
        conn,
        error = %{kind: _, reason: %{message: msg, plug_status: status}, stack: _}
      ) do
    Logger.error("Request error: #{inspect(error)}")
    send_resp(conn, status, msg)
  end

  def handle_errors(conn, error) do
    Logger.error("Request error: #{inspect(error)}")
    send_resp(conn, conn.status, "Internal server error")
  end

  defp run_function(fun, params, timeout \\ 5000) do
    Logger.debug("Safely running a function with params: #{inspect(params)}")
    ref = make_ref()
    me = self()
    Process.flag(:trap_exit, true)

    pid =
      spawn_link(fn ->
        result = fun.(params)
        Logger.debug("Got result: #{inspect(result)}")
        send(me, {ref, result})
      end)

    receive do
      {^ref, result} ->
        consume_exit()
        {:ok, result}

      {:EXIT, _, _} ->
        {:error, :crash}
    after
      timeout ->
        Process.exit(pid, :kill)
        consume_exit()
        {:error, :timeout}
    end
  end

  defp consume_exit do
    receive do
      {:EXIT, _, _} ->
        :ok
    after
      0 ->
        :ok
    end
  end
end
