defmodule Crack do
  alias Shared.CleanText
  alias Shared.Configuration
  alias Shared.Files
  alias Shared.FractionMap

  @spec main([binary()]) :: :ok | :error
  def main(args) do
    {flags, _remaining, _invalid} = parse_flags(args)

    case Files.read_input_text() do
      :error -> :error
      text -> dispatch(text, flags)
    end
  end

  defp parse_flags(args) do
    OptionParser.parse(args,
      # brute_force becomes pattern to parse --brute-force
      strict: [brute_force: :boolean, max_key_length: :integer],
      aliases: [b: :brute_force, m: :max_key_length]
    )
  end

  @spec dispatch(String.t(), OptionParser.parsed()) :: :ok | :error
  defp dispatch(raw_text, flags) do
    cond do
      List.keymember?(flags, :brute_force, 0) ->
        max_key_length =
          if not List.keymember?(flags, :max_key_length, 0) do
            Configuration.max_key_length_to_try()
          else
            elem(List.keyfind!(flags, :max_key_length, 0), 1)
          end

        try_brute_force(raw_text, max_key_length)

      true ->
        IO.puts("Missing input flags for crack program")
        :error
    end
  end

  @spec try_brute_force(String.t(), integer()) :: :ok | :error
  defp try_brute_force(raw_text, max_key_length) do
    frac_map = Files.force_read_freq_fraction_map()
    graphemes = CleanText.clean_text(raw_text)

    # Lazily run test_length on every length between 1 and max.
    Stream.unfold(
      1,
      fn length -> {test_length(graphemes, frac_map, length), length + 1} end
    )
    |> Enum.take(max_key_length)

    # TODO which is lowest, recalculate and try to solve that one.

    :ok
  end

  @spec test_length([String.grapheme()], FractionMap.t(), integer()) :: float()
  defp test_length(graphemes, real_frac_map, specific_length) do
    # Assume graphemes are interleaved per-element by some key of length specific_length.
    # Put graphemes affected by the same key letter into their own list.
    # If we've guessed correct length, these will be valid Caesar ciphers.
    caesar_grapheme_lists =
      Stream.unfold(0, fn offset ->
        {uninterleave_caesar(graphemes, specific_length, offset), offset + 1}
      end)
      |> Enum.take(specific_length)

    # Get fraction (letter frequency) maps for each previously
    # interleaved Caesar cipher.
    caesar_frac_maps =
      caesar_grapheme_lists
      |> Enum.map(&FractionMap.calculate_total(&1))
      |> Enum.with_index()
      |> Enum.map(fn {count_map, index} ->
        FractionMap.calculate_fraction(count_map, length(Enum.at(caesar_grapheme_lists, index)))
      end)

    # Find the best matching solution for each of the Caesar ciphers.
    # Then calculate a weighted deviation against the ideal letter frequencies.
    # Sum the deviations together and divide by our length guess to get a number
    # (normalized deviation) that can be compared against other length guesses.
    caesar_frac_maps
    |> Enum.map(fn current -> find_best_caesar_match(current, real_frac_map) end)
    |> Enum.map(fn {deviation, _best_match} -> deviation end)
    |> Enum.reduce(0, fn deviation, sum -> sum + deviation end)
    # TODO remove
    |> IO.inspect()
    |> then(fn sum -> sum / specific_length end)
  end

  @spec uninterleave_caesar([String.grapheme()], integer(), integer()) :: [String.grapheme()]
  defp uninterleave_caesar(graphemes, modulo, offset) do
    graphemes
    |> Enum.with_index()
    |> Enum.filter(fn {_grapheme, index} ->
      Integer.mod(index, modulo) == offset
    end)
    |> Enum.map(fn {grapheme, _index} -> grapheme end)
  end

  @spec find_best_caesar_match(FractionMap.t(), FractionMap.t()) ::
          {float(), integer()}
  defp find_best_caesar_match(curr_frac_map, real_frac_map) do
    # TODO order both alphabetically or by fraction but both must be same, then rotate a full length of iterations and compare weighted deviation
    # deviation = (alphabet_length - frac_descending_position) * frac
    # net_deviation = abs(deviation_a - deviation_b)
    # or something like that
    # need to do this for all elems and sum together

    # {deviation, key_offset} what the caesar key is
    {0.0, 0}
  end
end
