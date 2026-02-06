defmodule Mix.Tasks.Crack do
  @moduledoc "Printed when the user requests `mix help crack`"
  @shortdoc "Runs the crack program with passed args"

  use Mix.Task

  @impl Mix.Task
  @spec run([binary()]) :: :ok | :error
  def run(args) do
    Crack.main(args)
  end
end
