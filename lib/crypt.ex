defmodule Crypt do
  alias VCipher.Configuration
  alias VCipher.CleanText
  alias VCipher.Conversion

  @spec main([binary()]) :: :ok | :error
  def main(args) do
    {flags, _remaining, _invalid} = parse_flags(args)
    # TODO handle invalid

    case read_input_text() do
      :error -> :error
      text -> dispatch(text, flags)
    end
  end

  defp parse_flags(args) do
    OptionParser.parse(args,
      strict: [encode: :boolean, decode: :boolean, key: :string],
      aliases: [e: :encode, d: :decode, k: :key]
    )
  end

  @spec read_input_text() :: String.t() | :error
  defp read_input_text() do
    # TODO hangs on no input, dispatch to a process with timeout instead.
    case IO.read(:stdio, :eof) do
      :eof ->
        IO.puts("The text file was empty or errored!")
        :error

      {:error, reason} ->
        IO.puts("Failed to read input text file: " <> reason)
        :error

      text ->
        text
    end
  end

  @spec dispatch(String.t(), OptionParser.parsed()) :: :ok | :error
  defp dispatch(raw_text, flags) do
    cond do
      not List.keymember?(flags, :key, 0) ->
        IO.puts("No key provided")
        :error

      List.keymember?(flags, :encode, 0) ->
        raw_key = elem(List.keyfind!(flags, :key, 0), 1)
        encode(raw_text, raw_key)

      List.keymember?(flags, :decode, 0) ->
        raw_key = elem(List.keyfind!(flags, :key, 0), 1)
        decode(raw_text, raw_key)
    end
  end

  @spec encode(String.t(), String.t()) :: :ok | :error
  defp encode(raw_text, raw_key) do
    message = CleanText.clean_text(raw_text)
    key = CleanText.clean_text(raw_key)

    # Hacky input validation. TODO remove
    case String.equivalent?(String.downcase(raw_key), Enum.join(key)) do
      false ->
        IO.puts("The key is not in the alphabet, aborting!")
        :error

      true ->
        message_values = Conversion.to_values(message)
        key_values = Conversion.to_values(key)

        ciphertext =
          apply_key(message_values, key_values, true)
          |> Conversion.to_letters()

        # TODO not hardcode output
        File.write!("ciphertext_output.txt", ciphertext)
    end
  end

  @spec decode(String.t(), String.t()) :: :ok | :error
  defp decode(raw_text, raw_key) do
    ciphertext = CleanText.clean_text(raw_text)
    key = CleanText.clean_text(raw_key)

    message_values = Conversion.to_values(ciphertext)
    key_values = Conversion.to_values(key)

    message =
      apply_key(message_values, key_values, false)
      |> Conversion.to_letters()

    # TODO not hardcode output
    File.write!("message_output.txt", message)
  end

  @spec apply_key([integer()], [integer()], boolean()) :: [integer()]
  defp apply_key(values, key, wants_encode) do
    func = fn {value, index} ->
      if(wants_encode,
        do: value + Enum.at(key, rem(index, length(key))),
        else: value - Enum.at(key, rem(index, length(key)))
      )
      # Convert so value is always non-negative and within limits.
      |> Integer.mod(String.length(Configuration.alphabet()))
    end

    Enum.with_index(values)
    |> Enum.map(func)
  end
end
