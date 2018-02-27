defmodule Proc.TLV do

  def parse(binary) when is_binary(binary) do
    parse(binary, [])
  end

  defp parse(<<type, length, payload::size(length), rest::bits>>, result) do
    parse rest, [{type, payload} | result]
  end
  defp parse(rest, result) do
    {Enum.reverse(result), rest}
  end

  def build(tlvs) when is_list(tlvs) do
    build(tlvs, [])
  end

  defp build([], result) do
    IO.iodata_to_binary(result)
  end
  defp build([{type, payload} | rest], result) when is_integer(type) and is_bitstring(payload) do
    build rest, [result | <<type, byte_size(payload), payload::binary>>]
  end
  defp build([type | rest], result) when is_integer(type) do
    build rest, [result | <<type, 0>>]
  end
end
