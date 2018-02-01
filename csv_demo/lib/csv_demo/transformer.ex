defmodule CsvDemo.Transformer do
  def in_state(input, output, state \\ "UT") do
    process(input, output, fn stream ->
      stream
      |> Stream.filter(&(&1.state == state))
    end)
  end

  def registration(input, output) do
    process(input, output, fn stream ->
      stream
      |> Stream.filter(
        &(&1.last |> String.to_charlist() |> Enum.at(0) |> (fn x -> x in ?A..?K end).())
      )
      |> Stream.filter(&(Date.diff(Date.utc_today(), &1.birthday) > 18 * 365))
    end)
  end

  def john(input, output) do
    process(input, output, fn stream ->
      stream
      |> Stream.map(&(%{&1 | first: "John Jacob Jingleheimer", last: "Smith"} |> IO.inspect()))
    end)
  end

  def add_full_name(input, output) do
    process(
      input,
      output,
      fn stream ->
        stream
        |> Stream.map(&Map.put(&1, :full_name, "#{&1.first} #{&1.last}"))
        |> Stream.map(&Map.drop(&1, [:first, :last]))
      end,
      &generic_build_line/1
    )
  end

  defp process(input, output, transformer, builder \\ &build_line/1) do
    with out = output |> Path.expand() |> File.stream!() do
      input
      |> Path.expand()
      |> File.stream!()
      |> Stream.drop(1)
      |> Stream.map(&parse_line/1)
      |> transformer.()
      |> Stream.map(builder)
      |> Enum.into(out)
    end
  end

  defp parse_line(line) do
    [first, last, phone, street, city, zip, state, birthday] =
      line |> String.trim() |> String.split(",")

    %{
      first: first,
      last: last,
      phone: phone,
      street: street,
      city: city,
      zip: zip,
      state: state,
      birthday: Date.from_iso8601!(birthday)
    }
  end

  defp build_line(%{
         first: first,
         last: last,
         phone: phone,
         street: street,
         city: city,
         zip: zip,
         state: state,
         birthday: birthday
       }) do
    [first, last, phone, street, city, zip, state, to_string(birthday)]
    |> Enum.join(",")
    |> (&(&1 <> "\n")).()
  end

  defp generic_build_line(map) do
    map
    |> Map.values()
    |> Enum.join(",")
    |> (&(&1 <> "\n")).()
  end
end
