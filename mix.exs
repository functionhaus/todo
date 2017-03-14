defmodule Todo.Mixfile do
  use Mix.Project

  def project do
    [app: :todo,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :cowboy,
        :plug
      ],
      mod: {Todo.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "1.1.2"},
      {:plug, "1.3.3"},
      {:meck, "0.8.4", only: :test},
      {:httpoison, "0.11.1", only: :test}
    ]
  end
end
