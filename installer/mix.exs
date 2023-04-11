for path <- :code.get_path(),
    Regex.match?(~r/maxo_new-[\w\.\-]+\/ebin$/, List.to_string(path)) do
  Code.delete_path(path)
end

defmodule MaxoNew.MixProject do
  use Mix.Project

  def project do
    [
      app: :maxo_new,
      version: "0.1.0",
      elixir: "~> 1.14",
      # reuse build artefacts
      build_path: "../_build",
      deps_path: "../deps",
      lockfile: "../mix.lock",
      # colocated tests
      test_paths: ["test", "lib"],
      test_pattern: "*_test.exs",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:maxo_test_iex, "~> 0.1", only: [:test]},
      {:mneme, "~> 0.3", only: [:test]}
    ]
  end
end
