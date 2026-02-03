defmodule VCipher.MixProject do
  use Mix.Project

  def project do
    [
      app: :vcipher,
      version: "1.0.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      # Programs are run with custom mix tasks.
      # See /lib/mix/tasks for program entry points.
      # mix crypt ... to run the crypt task.
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
      # Mix tasks are used instead of the standard application entry point.
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 6.0"}
    ]
  end
end
