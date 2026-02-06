defmodule Mix.Tasks.Freq do
  @moduledoc "Printed when the user requests `mix help freq`"
  @shortdoc "Runs the freq program with passed args"

  use Mix.Task

  @impl Mix.Task
  @spec run([binary()]) :: :ok | :error
  def run(args) do
    Freq.main(args)
  end
end
