defmodule Shared.Files do
  alias Shared.Configuration

  @spec read_input_text() :: String.t() | :error
  def read_input_text() do
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

  def force_read_freq_fraction_map() do
    File.read!(Configuration.freq_path())
    |> Poison.decode!(as: %{})
  end

  def force_write_freq_fraction_map(map) do
    json = Poison.encode!(map, pretty: true)
    File.write!(Configuration.freq_path(), json)
  end
end
