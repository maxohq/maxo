defmodule LibName.MixProject do
  use Mix.Project
  @github_url "https://github.com/maxohq/lib_name"
  @version "0.1.0"
  @description "LibName description"

  def project do
    [
      app: :lib_name,
      source_url: @github_url,
      version: @version,
      description: @description,
      elixir: "~> 1.14",
      test_paths: ["test", "lib"],
      test_pattern: "*_test.exs",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LibName.Application, []}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "Github" => @github_url,
        "Changelog" => "#{@github_url}/blob/main/CHANGELOG.md"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:maxo_test_iex, "~> 0.1", only: [:test]},
      {:mneme, "~> 0.3", only: [:test]}
    ]
  end
end
