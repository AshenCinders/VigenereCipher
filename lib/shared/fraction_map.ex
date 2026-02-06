defmodule Shared.FractionMap do
  # Key is a grapheme (letter), value is the fraction the given letter occurrs in a given text (actual_times/total_letters).
  @type t :: %{String.grapheme() => float()}

  # Key is a grapheme, value is the TOTAL number of occurrences for that grapheme in some text.
  @type count_map :: %{String.grapheme() => integer()}

  # Iterates through input list of graphemes and produces a map with
  # the frequency of each grapheme as value, with the grapheme as key
  # Equivalent to Enum.frequencies, but more fun :D.
  @spec calculate_total([String.grapheme()]) :: count_map()
  def calculate_total(graphemes) do
    calculate_total_iter(graphemes, %{})
  end

  # Base case, empty list of graphemes.
  @spec calculate_total_iter([String.grapheme()], count_map()) :: count_map()
  defp calculate_total_iter([], result) do
    result
  end

  # Recursive case.
  @spec calculate_total_iter([String.grapheme()], count_map()) :: count_map()
  defp calculate_total_iter(graphemes, result) do
    calculate_total_iter(
      tl(graphemes),
      # Increment current value. If it doesnt exist, set to 1 (first found occurrence).
      Map.update(result, hd(graphemes), 1, fn stored -> stored + 1 end)
    )
  end

  # Converts total letter frequency map to the fractional
  # frequency of the letters with respect to the total count.
  @spec calculate_fraction(count_map(), integer()) :: t()
  def calculate_fraction(frequency_map, total_count) do
    Map.new(frequency_map, fn {key, value} -> {key, value / total_count} end)
  end
end
