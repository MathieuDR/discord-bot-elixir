defmodule Bot.Shared.ConsoleLogger.JasonSafeFormatter do
  @moduledoc """
  Copy pasted from `LoggerJSON` 5.1.4:
  https://github.com/Nebo15/logger_json/blob/5.1.4/lib/logger_json/jason_safe_formatter.ex

  Was removed in `LoggerJSON` 6.0 but it's convenient for our local `Backend.Shared.ConsoleLogger`.
  """

  @doc """
  Produces metadata that is "safe" for calling Jason.encode!/1 on without errors.
  This means that unexpected Logger metadata won't cause logging crashes.

  Current formatting is...
    * Maps: as is
    * Printable binaries: as is
    * Numbers: as is
    * Structs that don't implement Jason.Encoder: converted to maps
    * Tuples: converted to lists
    * Keyword lists: converted to Maps
    * everything else: inspected
  """
  @spec format(any()) :: any()
  def format(%Jason.Fragment{} = data) do
    data
  end

  def format(nil), do: nil
  def format(true), do: true
  def format(false), do: false
  def format(data) when is_atom(data), do: data

  def format(%_struct{} = data) do
    if jason_implemented?(data) do
      data
    else
      data
      |> Map.from_struct()
      |> format()
    end
  end

  def format(%{} = data) do
    for {key, value} <- data, into: %{}, do: {format_map_key(key), format(value)}
  end

  def format([{key, _} | _] = data) when is_atom(key) do
    Map.new(data, fn
      {key, value} -> {format_map_key(key), format(value)}
    end)
  rescue
    _ -> for(d <- data, do: format(d))
  end

  def format({key, data}) when is_binary(key) or is_atom(key),
    do: %{format_map_key(key) => format(data)}

  def format(data) when is_tuple(data), do: data |> Tuple.to_list() |> format()

  def format(data) when is_number(data), do: data

  def format(data) when is_binary(data), do: format_binary(data)

  def format(data) when is_list(data), do: for(d <- data, do: format(d))

  def format(data), do: inspect(data, pretty: true, width: 80)

  defp format_map_key(key) when is_binary(key), do: format_binary(key)
  defp format_map_key(key) when is_atom(key) or is_number(key), do: key
  defp format_map_key(key), do: inspect(key)

  defp format_binary(data) when is_binary(data) do
    if String.valid?(data) && String.printable?(data) do
      data
    else
      inspect(data)
    end
  end

  def jason_implemented?(data) do
    impl = Jason.Encoder.impl_for(data)
    impl && impl != Jason.Encoder.Any
  end
end
