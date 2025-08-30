defmodule Bot.Shared.ConsoleLogger do
  @moduledoc """
  Logs pretty JSON to the console, for local & testing purposes.
  """
  alias __MODULE__.JasonSafeFormatter

  @spec format(atom, term, Logger.Formatter.time_ms(), keyword()) :: IO.chardata()
  @doc """
  Formats the message with the help of LoggerJSON. All the metadata will be converted into a pretty print of JSON.
  """
  def format(level, message, _timestamp, metadata) do
    # Ignores a few keywords, see [docs](https://github.com/Nebo15/logger_json/blob/7ffa34e1fbf2ccb9a6b3a49fec8ed3783ebd9041/lib/logger_json.ex#L46)

    json =
      metadata
      |> take_all_except([
        :erl_level,
        :domain,
        :otel_trace_id,
        :otel_trace_flags,
        :otel_span_id
      ])
      |> encode()

    "[#{level}] #{message} \n%METADATA%\n#{json}\n\n"
  end

  defp take_all_except(metadata, keys) do
    metadata
    |> Map.new()
    |> LoggerJSON.Formatter.Metadata.take_metadata({:all_except, keys})
  end

  Inspect.List

  defp encode(metadata) do
    metadata
    |> Enum.map(fn {key, value} -> {key, charlist_to_string(value)} end)
    |> JasonSafeFormatter.format()
    |> Jason.encode!()
    |> Jason.Formatter.pretty_print()
  end

  defp charlist_to_string(list) when is_list(list) do
    if List.ascii_printable?(list) do
      List.to_string(list)
    else
      list
    end
  end

  defp charlist_to_string(other), do: other
end
