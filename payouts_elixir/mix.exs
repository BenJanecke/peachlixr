defmodule PayoutsElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :payouts_elixir,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:xml_builder, "~> 2.2"},
      {:sweet_xml, "~> 0.7.1"}
    ]
  end
end
