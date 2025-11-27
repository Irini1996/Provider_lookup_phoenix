defmodule ProviderLookup.CSV do
  @moduledoc false

  # Public: Parse a stream of CSV lines into lists of columns.
  def parse_stream(stream) do
    Stream.map(stream, &parse_line/1)
  end

  # Parse a single CSV line with support for quoted fields
  def parse_line(line) do
    line
    |> String.trim_trailing("\n")
    |> do_parse([], "", false)
    |> Enum.reverse()
  end

  # CSV parser (recursive)
  defp do_parse(<<>>, fields, current, _in_quotes) do
    [current | fields]
  end

  defp do_parse(<<?", rest::binary>>, fields, current, false) do
    do_parse(rest, fields, current, true)
  end

  defp do_parse(<<?", rest::binary>>, fields, current, true) do
    case rest do
      <<?", tail::binary>> ->  # escaped quote ""
        do_parse(tail, fields, current <> "\"", true)

      <<?,, tail::binary>> ->   # end quoted field
        do_parse(tail, [current | fields], "", false)

      <<>> ->  # end of line
        [current | fields]

      _ ->
        do_parse(rest, fields, current, false)
    end
  end

  defp do_parse(<<?,, rest::binary>>, fields, current, false) do
    do_parse(rest, [current | fields], "", false)
  end

  defp do_parse(<<char, rest::binary>>, fields, current, in_quotes) do
    do_parse(rest, fields, current <> <<char>>, in_quotes)
  end
end
