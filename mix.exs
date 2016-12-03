defmodule NovelReader.Mixfile do
  use Mix.Project

  @description """
  Desktop application that can read a Novel Updates feed and get translated
  chapters from translation sites.
  """

  def project do
    [
      app:             :novel_reader,
      version:         "0.1.0-dev",
      deps:            deps(),

      elixir:          "~> 1.3",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description:     @description,
      package:         package,

      name:            "Novel Reader",
      docs:            [
                         main: "NovelReader",
                         extras: ["README.md"]
                       ]
    ]
  end

  # Configuration for the OTP application

  def application do
    [applications: [:logger, :scrape, :floki, :parallel, :timex],
     mod: {NovelReader, []}]
  end

  defp deps do
    [
      {:scrape, "~> 1.2"},
      {:exvcr, "~> 0.8", only: :test},
      {:ex_doc, "~> 0.14", only: [:dev, :test]},
      {:mix_test_watch, "~> 0.2", only: [:dev, :test]},
      {:credo, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      maintainers: ["jinyeow"],
      licenses: ["MIT"],
      # links: %{"GitHub" => "https://github.com/jinyeow/novel_reader"}
    ]
  end
end
