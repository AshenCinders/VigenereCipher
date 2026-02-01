defmodule Shared.CleanText do
  alias Shared.Configuration

  @spec clean_text(String.t()) :: [String.grapheme()]
  def clean_text(message) do
    String.downcase(message)
    |> String.graphemes()
    |> Enum.filter(&in_alphabet/1)
  end

  defp in_alphabet(letter) do
    String.contains?(Configuration.alphabet(), letter)
  end
end
