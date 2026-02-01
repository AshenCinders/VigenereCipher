defmodule Shared.Conversion do
  alias Shared.Configuration

  @spec to_values([String.grapheme()]) :: [integer()]
  def to_values(graphemes) do
    for elem <- graphemes, do: Map.fetch!(map_letter_to_value(), elem)
  end

  @spec to_letters([integer()]) :: [String.grapheme()]
  def to_letters(values) do
    for elem <- values, do: Map.fetch!(map_value_to_letter(), elem)
  end

  @doc """
  %{
  "a" => 0,
  "b" => 1,
  "c" => 2,
  ...
  """
  def map_letter_to_value() do
    Configuration.alphabet()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.into(%{})
  end

  @doc """
  %{
  0 => "a",
  1 => "b",
  2 => "c",
  ...
  """
  def map_value_to_letter() do
    map_letter_to_value()
    |> Map.new(fn {key, val} -> {val, key} end)
  end
end
