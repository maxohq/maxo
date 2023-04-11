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
          binding: [app_name: "my_app", app_module: "MyApp"],
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

    # |> Map.put(:binding, clean_binding(project.binding))
  end

  # defp clean_binding(binding) do
  #   binding
  #   |> Keyword.put(
  #     :secret_key_base_dev,
  #     "N0TMlBsoiJnRILN4Fbwp7NN5PeuzjaxKrszSmvU+xYoXIarqbIuaqRRI2XKqXsxp"
  #   )
  #   |> Keyword.put(
  #     :secret_key_base_test,
  #     "0FFfOkBrw43N3lvFcJLh7e1dweRG9SLbSAkhopP/JdedPgwtpU+Y6JcG2JSsQ/8r"
  #   )
  #   |> Keyword.put(:signing_salt, "eJEULGk4")
  #   |> Keyword.put(:lv_signing_salt, "XAYEV79U")
  #   |> clean_adapter_config()
  # end

  # defp clean_adapter_config(binding) do
  #   adapter_config = Keyword.get(binding, :adapter_config)
  #   test = Keyword.get(adapter_config, :test)
  #   adapter_config = Keyword.put(adapter_config, :test, test)
  #   Keyword.put(binding, :adapter_config, adapter_config)
  # end
end
