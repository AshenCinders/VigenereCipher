defmodule Crack do
  alias Shared.CleanText
  alias Shared.Configuration
  alias Shared.Files
  alias Shared.FractionMap
  alias Shared.Conversion
  alias Crypt

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
    brute_force_result =
      Stream.unfold(
        1,
        fn length -> {test_length(graphemes, frac_map, length), length + 1} end
      )
      |> Enum.take(max_key_length)

    best_guess = elem(Enum.min_by(brute_force_result, fn {deviation, _guess} -> deviation end), 1)

    IO.puts("\nBrute-force attempt finished, the best key-guess is: ")
    IO.inspect(best_guess)
    IO.puts("Results for length checks with deviation: ")
    IO.inspect(brute_force_result)

    IO.puts("\nRunning automatic decode from best guess..")
    Crypt.decode(raw_text, best_guess)
    IO.puts("Finished decoding. See message output text file")

    :ok
  end

  @spec test_length([String.grapheme()], FractionMap.t(), integer()) :: {float(), String.t()}
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
    # (homebrewed normalized deviation) that can be compared against other length guesses.
    best_caesars =
      caesar_frac_maps
      |> Enum.map(fn current -> find_best_caesar_match(current, real_frac_map) end)

    normalized_deviation =
      best_caesars
      |> Enum.map(fn {deviation, _best_letter} -> deviation end)
      |> Enum.reduce(0, fn deviation, sum -> sum + deviation end)
      |> then(fn sum -> sum / specific_length end)

    key_guess =
      best_caesars
      |> Enum.map(fn {_deviation, best_letter} -> best_letter end)
      |> Conversion.to_letters()
      |> Enum.join()

    {normalized_deviation, key_guess}
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

  # (Visually) put both maps in ordered lines. Each element in one map corresponds to another.
  # Calculate the summed deviation of all corresponding map elements (|a1 - b1| + |a2 - b2| + ...).
  # Note the result down, and rotate one map forward one step,
  # so that each element has a new corresponding element in the other map.
  # Keep rotating and calculating summed deviation for all possible ordered match-ups.
  # Return the best match-up, which has the lowest deviation.
  # The rotation that was the best (hopefully) corresponds to a letter in the key.
  # E.g. if best rotation was with offset 4, then the letter is "e".
  @spec find_best_caesar_match(FractionMap.t(), FractionMap.t()) ::
          {float(), integer()}
  defp find_best_caesar_match(curr_frac_map, real_frac_map) do
    Stream.unfold(0, fn rot_offset ->
      {sum_deviation(real_frac_map, curr_frac_map, rot_offset), rot_offset + 1}
    end)
    |> Enum.take(Configuration.alphabet_length())
    |> Enum.min_by(fn {deviation, _rotation} -> deviation end)
  end

  @spec sum_deviation(FractionMap.t(), FractionMap.t(), integer()) :: {float(), integer()}
  defp sum_deviation(real_frac_map, curr_frac_map, rot_offset) do
    length = Configuration.alphabet_length()
    alphabet = Configuration.alphabet() |> String.graphemes()

    Enum.map(0..(length - 1), fn i ->
      real_weight = Map.fetch!(real_frac_map, Enum.at(alphabet, i))

      curr_weight =
        Map.fetch!(curr_frac_map, Enum.at(alphabet, Integer.mod(i + rot_offset, length)))

      index_for_weights =
        Enum.find_index(sorted_alphabet(real_frac_map), fn elem ->
          elem == Enum.at(alphabet, i)
        end)

      # Weight is inverse to index in alphabet list, first gets highest weight, last gets 0 weight.
      real_deviation = (length - index_for_weights - 1) * real_weight
      curr_deviation = (length - index_for_weights - 1) * curr_weight
      abs(real_deviation - curr_deviation)
    end)
    |> Enum.sum()
    |> then(fn sum -> {sum, rot_offset} end)
  end

  # Alphabet descending by weight.
  @spec sorted_alphabet(FractionMap.t()) :: [String.grapheme()]
  defp sorted_alphabet(frac_map) do
    Map.to_list(frac_map)
    |> Enum.sort(fn {_g1, w1}, {_g2, w2} -> w1 >= w2 end)
    |> Enum.map(fn {grapheme, _weight} -> grapheme end)
  end
end
