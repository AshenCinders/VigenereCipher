defmodule Shared.Configuration do
  # Current alphabet (Swedish) used for the cipher.
  def alphabet() do
    "abcdefghijklmnopqrstuvwxyzåäö"
  end

  def freq_path() do
    "fraction_map.json"
  end
end
