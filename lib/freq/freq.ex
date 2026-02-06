defmodule Freq do
  alias Shared.CleanText
  alias Shared.Files
  alias Shared.FractionMap

  @spec main([binary()]) :: :ok | :error
  def main(_args) do
    case Files.read_input_text() do
      :error ->
        :error

      raw_text ->
        graphemes = CleanText.clean_text(raw_text)

        FractionMap.calculate_total(graphemes)
        |> FractionMap.calculate_fraction(length(graphemes))
        |> Files.force_write_freq_fraction_map()
    end
  end
end
