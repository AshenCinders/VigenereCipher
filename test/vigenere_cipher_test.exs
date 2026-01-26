defmodule VigenereCipherTest do
  use ExUnit.Case
  doctest VigenereCipher

  test "greets the world" do
    assert VigenereCipher.hello() == :world
  end
end
