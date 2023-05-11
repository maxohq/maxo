defmodule MaxoNew.LibGen.LibPackageTest do
  use ExUnit.Case
  use MnemeDefaults
  alias MaxoNew.LibGen.LibDesc
  alias MaxoNew.LibGen.LibPackage
  alias MaxoNew.Virtfs

  test "works ok" do
    p = LibDesc.new("maxo_gen", [])
    p |> LibPackage.prepare_project() |> LibPackage.generate()

    auto_assert(
      [
        "/maxo_gen/.formatter.exs",
        "/maxo_gen/.github",
        "/maxo_gen/.github/workflows",
        "/maxo_gen/.github/workflows/ci.yml",
        "/maxo_gen/.gitignore",
        "/maxo_gen/CHANGELOG.md",
        "/maxo_gen/LICENCE",
        "/maxo_gen/Makefile",
        "/maxo_gen/README.md",
        "/maxo_gen/bin",
        "/maxo_gen/bin/setup",
        "/maxo_gen/bin/test",
        "/maxo_gen/bin/test_iex",
        "/maxo_gen/config",
        "/maxo_gen/config/config.exs",
        "/maxo_gen/examples",
        "/maxo_gen/examples/example.exs",
        "/maxo_gen/examples/example.tape",
        "/maxo_gen/examples/gen_tape.exs",
        "/maxo_gen/lib",
        "/maxo_gen/lib/maxo_gen",
        "/maxo_gen/lib/maxo_gen.ex",
        "/maxo_gen/lib/maxo_gen/application.ex",
        "/maxo_gen/lib/maxo_gen_test.exs",
        "/maxo_gen/lib/test_helper.exs",
        "/maxo_gen/mix.exs",
        "/maxo_gen/test",
        "/maxo_gen/test/support",
        "/maxo_gen/test/support/mneme_defaults.ex",
        "/maxo_gen/test/test_helper.exs"
      ] <- Virtfs.tree!(p.fs, "/maxo_gen")
    )

    auto_assert(
      ## simple text contains interpolation, this breaks assertions
      """
      defmodule MaxoGen.MixProject do
        use Mix.Project
        @github_url "https://github.com/maxohq/maxo_gen"
        @version "0.1.0"
        @description "MaxoGen description"

        def project do
          [
            app: :maxo_gen,
            source_url: @github_url,
            version: @version,
            description: @description,
            elixir: "~> 1.14",
            elixirc_paths: elixirc_paths(Mix.env()),
            test_paths: ["test", "lib"],
            test_pattern: "*_test.exs",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            package: package(), 
            docs: [extras: ["README.md"]]
          ]
        end

        # Run "mix help compile.app" to learn about applications.
        def application do
          [
            extra_applications: [:logger],
            mod: {MaxoGen.Application, []}
          ]
        end

        def elixirc_paths(:test), do: ["lib", "test/support"]
        def elixirc_paths(_), do: ["lib"]

        defp package do
          [
            files: ~w(lib mix.exs README* CHANGELOG*),
            licenses: ["MIT"],
            links: %{
              "Github" => @github_url,
              "Changelog" => "github_url/blob/main/CHANGELOG.md"
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
      """ <-
        Virtfs.read!(p.fs, "/maxo_gen/mix.exs")
        |> String.replace(~S|#{@github_url}|, "github_url")
    )

    auto_assert(
      """
      defmodule MaxoGenTest do
        use ExUnit.Case
        use MnemeDefaults

        test "greeting" do
          auto_assert(MaxoGen.greeting())
        end
      end
      """ <- Virtfs.read!(p.fs, "/maxo_gen/lib/maxo_gen_test.exs")
    )

    assert Virtfs.read!(p.fs, "/maxo_gen/CHANGELOG.md") =~ LibPackage.today_str()
    assert Virtfs.read!(p.fs, "/maxo_gen/LICENCE") =~ LibPackage.year_str()
  end

  test "with options" do
    p = LibDesc.new("maxo_dbinspect", module: DbInspect, app: :db_inspect)
    p |> LibPackage.prepare_project() |> LibPackage.generate()

    auto_assert(
      [
        "/maxo_dbinspect",
        "/maxo_dbinspect/.formatter.exs",
        "/maxo_dbinspect/.github",
        "/maxo_dbinspect/.github/workflows",
        "/maxo_dbinspect/.github/workflows/ci.yml",
        "/maxo_dbinspect/.gitignore",
        "/maxo_dbinspect/CHANGELOG.md",
        "/maxo_dbinspect/LICENCE",
        "/maxo_dbinspect/Makefile",
        "/maxo_dbinspect/README.md",
        "/maxo_dbinspect/bin",
        "/maxo_dbinspect/bin/setup",
        "/maxo_dbinspect/bin/test",
        "/maxo_dbinspect/bin/test_iex",
        "/maxo_dbinspect/config",
        "/maxo_dbinspect/config/config.exs",
        "/maxo_dbinspect/examples",
        "/maxo_dbinspect/examples/example.exs",
        "/maxo_dbinspect/examples/example.tape",
        "/maxo_dbinspect/examples/gen_tape.exs",
        "/maxo_dbinspect/lib",
        "/maxo_dbinspect/lib/db_inspect",
        "/maxo_dbinspect/lib/db_inspect.ex",
        "/maxo_dbinspect/lib/db_inspect/application.ex",
        "/maxo_dbinspect/lib/db_inspect_test.exs",
        "/maxo_dbinspect/lib/test_helper.exs",
        "/maxo_dbinspect/mix.exs",
        "/maxo_dbinspect/test",
        "/maxo_dbinspect/test/support",
        "/maxo_dbinspect/test/support/mneme_defaults.ex",
        "/maxo_dbinspect/test/test_helper.exs"
      ] <- Virtfs.tree!(p.fs, "/")
    )

    auto_assert(
      """
      defmodule DbInspect.MixProject do
        use Mix.Project
        @github_url "https://github.com/maxohq/db_inspect"
        @version "0.1.0"
        @description "DbInspect description"

        def project do
          [
            app: :db_inspect,
            source_url: @github_url,
            version: @version,
            description: @description,
            elixir: "~> 1.14",
            elixirc_paths: elixirc_paths(Mix.env()),
            test_paths: ["test", "lib"],
            test_pattern: "*_test.exs",
            start_permanent: Mix.env() == :prod,
            deps: deps(),
            package: package(), 
            docs: [extras: ["README.md"]]
          ]
        end

        # Run "mix help compile.app" to learn about applications.
        def application do
          [
            extra_applications: [:logger],
            mod: {DbInspect.Application, []}
          ]
        end

        def elixirc_paths(:test), do: ["lib", "test/support"]
        def elixirc_paths(_), do: ["lib"]

        defp package do
          [
            files: ~w(lib mix.exs README* CHANGELOG*),
            licenses: ["MIT"],
            links: %{
              "Github" => @github_url,
              "Changelog" => "@github_url/blob/main/CHANGELOG.md"
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
      """ <-
        Virtfs.read!(p.fs, "/maxo_dbinspect/mix.exs")
        |> String.replace(~S|#{@github_url}|, "@github_url")
    )
  end
end
