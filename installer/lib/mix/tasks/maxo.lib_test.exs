defmodule Mix.Tasks.Maxo.LibTest do
  use ExUnit.Case, async: true
  alias Mix.Tasks.Maxo.Lib, as: MaxoLib
  use MnemeDefaults
  alias MaxoNew.Virtfs

  describe "unit_test_project" do
    test "just path" do
      res = MaxoLib.unit_test_project("my_app")

      auto_assert(
        %MaxoNew.LibGen.LibDesc{
          app: "my_app",
          app_mod: MyApp,
          app_test: "my_app_test",
          base_path: "my_app",
          binding: [today: "2023-04-11", app_name: "my_app", app_module: "MyApp"],
          opts: [],
          project_path: "my_app"
        } <- remove_instable_values(res)
      )
    end
  end

  describe "unit_test_args" do
    test "just path" do
      ExUnit.CaptureIO.capture_io(fn ->
        res = MaxoLib.unit_test_args("my_app")

        auto_assert(
          [
            "/my_app",
            "/my_app/.formatter.exs",
            "/my_app/.github",
            "/my_app/.github/workflows",
            "/my_app/.github/workflows/ci.yml",
            "/my_app/.gitignore",
            "/my_app/CHANGELOG.md",
            "/my_app/Makefile",
            "/my_app/README.md",
            "/my_app/config",
            "/my_app/config/config.exs",
            "/my_app/examples",
            "/my_app/examples/example.exs",
            "/my_app/examples/example.tape",
            "/my_app/examples/gen_tape.exs",
            "/my_app/lib",
            "/my_app/lib/my_app",
            "/my_app/lib/my_app.ex",
            "/my_app/lib/my_app/application.ex",
            "/my_app/lib/my_app_test.exs",
            "/my_app/lib/test_helper.exs",
            "/my_app/mix.exs",
            "/my_app/test",
            "/my_app/test/test_helper.exs"
          ] <- Virtfs.tree!(res.fs, "/")
        )
      end)

      # IO.inspect(res, limit: :infinity)
    end
  end

  defp remove_instable_values(project) do
    project
    |> Map.delete(:fs)
    |> Map.put(:binding, clean_binding(project.binding))
  end

  defp clean_binding(binding) do
    binding
    |> Keyword.put(
      :today,
      "2023-04-11"
    )
  end
end
