defmodule Swapi.HTTP do
  require Logger

#  def get(url, headers \\ []) do
#    with url = String.to_charlist(url),
#         http_options = [autoredirect: true],
#         options = [body_format: :binary],
#         response = :httpc.request(:get, {url, headers}, http_options, options) do
#      case response do
#        {:ok, {{_, status, _}, _, body}} when status in 200..299 ->
#          {:ok, body}
#
#        _ ->
#          :error
#      end
#    end
#  end

  def get(url, headers \\ []) do
    HTTPoison.get(url, headers, [follow_redirect: true])
    |> case do
      {:ok, %{body: body, status_code: code}} when code in 200..299 ->
        body
      _ ->
        nil
    end
  end

  def get_stream(url) do
    Stream.resource(
      fn -> url end,
      fn
        nil ->
          {:halt, nil}

        url ->
          get(url)
          |> Poison.decode()
          |> case do
            {:ok, %{"results" => results, "next" => next}} ->
              {results, next}
            {:error, reason} ->
              Logger.error "Failed to parse results from #{url} reason: #{inspect reason}"
              raise "Parse error"
          end
      end,
      fn _ -> :ok end
    )
  end
end
