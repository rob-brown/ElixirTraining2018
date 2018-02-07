defmodule Shorty.Router do
  use Plug.Router
  use Plug.ErrorHandler
  require Logger

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/shorten" do
    with {:ok, url, conn} <- read_body(conn),
         id = Shorty.shorten(url),
         response = format_url(conn, id) do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(:ok, response)
    else
      _ ->
        conn
        |> send_resp(:internal_server_error, "Internal Server Error")
    end
  end

  get "/s/:id" do
    with {:ok, url} <- Shorty.lookup(id), body = redirect_body(url) do
      conn
      |> put_resp_header("Location", url)
      |> put_resp_header("Referrer-Policy", "unsafe-url")
      |> put_resp_content_type("text/html")
      |> send_resp(:moved_permanently, body)
    else
      _ ->
        conn
        |> send_resp(:not_found, "Not Found")
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

  defp format_url(%Plug.Conn{host: host, port: 80}, id) do
    "http://#{host}/s/#{id}"
  end

  defp format_url(%Plug.Conn{host: host, port: port}, id) do
    "http://#{host}:#{port}/s/#{id}"
  end

  defp redirect_body(url) do
    """
    <html>
    <head><title>Shorty</title></head>
    <body><a href="#{url}">Moved here</a></body>
    </html>
    """
  end
end
