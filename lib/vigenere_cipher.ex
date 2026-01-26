defmodule VCipher.Main do
  @spec main([binary()]) :: :ok | :error
  def main(args) do
    {flags, _remaining, _invalid} = parse_flags(args)
    # TODO handle invalid

    case IO.read(:stdio, :eof) do
      :eof ->
        IO.puts("The text file was empty or errored!")
        :error

      {:error, reason} ->
        IO.puts("Failed to read input text file: " <> reason)
        :error

      text ->
        dispatch(text, flags)
    end
  end

  defp parse_flags(args) do
    OptionParser.parse(args,
      strict: [encode: :boolean, decode: :boolean, key: :string],
      aliases: [e: :encode, d: :decode, k: :key]
    )
  end

  @spec dispatch(String.t(), OptionParser.parsed()) :: :ok | :error
  defp dispatch(raw_text, flags) do
    cond do
      not List.keymember?(flags, :key, 0) ->
        IO.puts("No key provided")
        :error
    end
  end
end