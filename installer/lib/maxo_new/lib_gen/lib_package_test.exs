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
        "/maxo_gen/Makefile",
        "/maxo_gen/README.md",
        "/maxo_gen/config",
        "/maxo_gen/config/config.exs",
        "/maxo_gen/lib",
        "/maxo_gen/lib/maxo_gen",
        "/maxo_gen/lib/maxo_gen.ex",
        "/maxo_gen/lib/maxo_gen/application.ex",
        "/maxo_gen/lib/maxo_gen_test.exs",
        "/maxo_gen/lib/test_helper.exs",
        "/maxo_gen/mix.exs",
        "/maxo_gen/test",
        "/maxo_gen/test/test_helper.exs"
      ] <- Virtfs.tree!(p.fs, "/maxo_gen")
    )

    auto_assert(
      ## simple text contains interpolation, this breaks assertions
      {:defmodule, [line: 1],
       [
         {:__aliases__, [line: 1], [:MaxoGen, :MixProject]},
         [
           do:
             {:__block__, [],
              [
                {:use, [line: 2], [{:__aliases__, [line: 2], [:Mix, :Project]}]},
                {:@, [line: 3],
                 [{:github_url, [line: 3], ["https://github.com/maxohq/maxo_gen"]}]},
                {:@, [line: 4], [{:version, [line: 4], ["0.1.0"]}]},
                {:@, [line: 5], [{:description, [line: 5], ["MaxoGen description"]}]},
                {:def, [line: 7],
                 [
                   {:project, [line: 7], nil},
                   [
                     do: [
                       app: :maxo_gen,
                       source_url: {:@, [line: 10], [{:github_url, [line: 10], nil}]},
                       version: {:@, [line: 11], [{:version, [line: 11], nil}]},
                       description: {:@, [line: 12], [{:description, [line: 12], nil}]},
                       elixir: "~> 1.14",
                       test_paths: ["test", "lib"],
                       test_pattern: "*_test.exs",
                       start_permanent:
                         {:==, [line: 16],
                          [
                            {{:., [line: 16], [{:__aliases__, [line: 16], [:Mix]}, :env]},
                             [line: 16], []},
                            :prod
                          ]},
                       deps: {:deps, [line: 17], []},
                       package: {:package, [line: 18], []}
                     ]
                   ]
                 ]},
                {:def, [line: 23],
                 [
                   {:application, [line: 23], nil},
                   [
                     do: [
                       extra_applications: [:logger],
                       mod: {{:__aliases__, [line: 26], [:MaxoGen, :Application]}, []}
                     ]
                   ]
                 ]},
                {:defp, [line: 30],
                 [
                   {:package, [line: 30], nil},
                   [
                     do: [
                       files:
                         {:sigil_w, [delimiter: "(", line: 32],
                          [{:<<>>, [line: 32], ["lib mix.exs README* CHANGELOG*"]}, []]},
                       licenses: ["MIT"],
                       links:
                         {:%{}, [line: 34],
                          [
                            {"Github", {:@, [line: 35], [{:github_url, [line: 35], nil}]}},
                            {"Changelog",
                             {:<<>>, [line: 36],
                              [
                                {:"::", [line: 36],
                                 [
                                   {{:., [line: 36], [Kernel, :to_string]}, [line: 36],
                                    [{:@, [line: 36], [{:github_url, [line: 36], nil}]}]},
                                   {:binary, [line: 36], nil}
                                 ]},
                                "/blob/main/CHANGELOG.md"
                              ]}}
                          ]}
                     ]
                   ]
                 ]},
                {:defp, [line: 42],
                 [
                   {:deps, [line: 42], nil},
                   [
                     do: [
                       {:{}, [line: 44], [:ex_doc, "~> 0.29", [only: :dev, runtime: false]]},
                       {:{}, [line: 45], [:maxo_test_iex, "~> 0.1", [only: [:test]]]},
                       {:{}, [line: 46], [:mneme, "~> 0.3", [only: [:test]]]}
                     ]
                   ]
                 ]}
              ]}
         ]
       ]} <- Code.string_to_quoted!(Virtfs.read!(p.fs, "/maxo_gen/mix.exs"))
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
  end
end
