defmodule Shared.Configuration do
  # Current alphabet (Swedish) used for the cipher.
  # Alphabet is assumed to be in valid ascending order.
  def alphabet() do
    "abcdefghijklmnopqrstuvwxyzåäö"
  end

  def alphabet_length do
    String.length(alphabet())
  end

  def freq_path() do
    "fraction_map.json"
  end

  def max_key_length_to_try do
    16
  end
end
