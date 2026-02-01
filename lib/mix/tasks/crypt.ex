defmodule Mix.Tasks.Crypt do
  @moduledoc "Printed when the user requests `mix help crypt`"
  @shortdoc "Runs the crypt program with passed args"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    Crypt.main(args)
  end
end
