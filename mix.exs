defmodule NovelReader.Mixfile do
  use Mix.Project

  def project do
    [app: :novel_reader,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application

  def application do
    [applications: [:logger, :scrape, :floki, :parallel, :timex],
     mod: {NovelReader, []}]
  end

  defp deps do
    [
      {:scrape, "~> 1.2"},
      {:exvcr, "~> 0.8", only: :test}
    ]
  end

  # TODO: add license
end
