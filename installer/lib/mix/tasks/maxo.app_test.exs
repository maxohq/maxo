defmodule Mix.Tasks.Maxo.AppTest do
  use ExUnit.Case, async: true
  alias Mix.Tasks.Maxo.App, as: MaxoApp
  use MnemeDefaults
  alias MaxoNew.Virtfs

  describe "unit_test_project" do
    test "just path" do
      res = MaxoApp.unit_test_project("my_app")

      # IO.inspect(res, limit: :infinity)

      auto_assert(
        %MaxoNew.Project{
          app: "my_app",
          app_mod: MyApp,
          app_path: "my_app",
          app_test: "my_app_test",
          base_path: "my_app",
          binding: [
            adapter_config: [
              test: [
                username: "postgres",
                password: "postgres",
                hostname: "localhost",
                database: {:literal, "\"my_app_test\#{System.get_env(\"MIX_TEST_PARTITION\")}\""},
                pool: Ecto.Adapters.SQL.Sandbox,
                pool_size: 10
              ],
              dev: [
                username: "postgres",
                password: "postgres",
                hostname: "localhost",
                database: "my_app_dev",
                stacktrace: true,
                show_sensitive_data_on_connection_error: true,
                pool_size: 10
              ],
              test_setup_all: "Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)",
              test_setup: """
                  pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MyApp.Repo, shared: not tags[:async])
                  on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)\
              """,
              prod_variables: """
              database_url =
                System.get_env("DATABASE_URL") ||
                  raise \"""
                  environment variable DATABASE_URL is missing.
                  For example: ecto://USER:PASS@HOST/DATABASE
                  \"""

              maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

              """,
              prod_config: """
              # ssl: true,
              url: database_url,
              pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
              socket_options: maybe_ipv6
              """
            ],
            lv_signing_salt: "XAYEV79U",
            signing_salt: "eJEULGk4",
            secret_key_base_test:
              "0FFfOkBrw43N3lvFcJLh7e1dweRG9SLbSAkhopP/JdedPgwtpU+Y6JcG2JSsQ/8r",
            secret_key_base_dev:
              "N0TMlBsoiJnRILN4Fbwp7NN5PeuzjaxKrszSmvU+xYoXIarqbIuaqRRI2XKqXsxp",
            app_name: "my_app",
            app_module: "MyApp",
            root_app_name: "my_app",
            root_app_module: "MyApp",
            lib_web_name: "my_app/web",
            web_app_name: "my_app",
            endpoint_module: "MyApp.Web.Endpoint",
            web_namespace: "MyApp.Web",
            phoenix_dep: "{:phoenix, \"~> 1.7.2\"}",
            phoenix_dep_umbrella_root: "{:phoenix, \"~> 1.7.2\"}",
            phoenix_js_path: "phoenix",
            phoenix_version: "1.7.2",
            pubsub_server: MyApp.PubSub,
            in_umbrella: false,
            asset_builders: [:tailwind, :esbuild],
            javascript: true,
            css: true,
            mailer: true,
            ecto: true,
            html: true,
            live: true,
            live_comment: nil,
            dashboard: true,
            gettext: true,
            adapter_app: :postgrex,
            adapter_module: Ecto.Adapters.Postgres,
            generators: nil,
            namespaced?: false,
            dev: false
          ],
          lib_web_name: "my_app/web",
          opts: [],
          project_path: "my_app",
          root_app: "my_app",
          root_mod: MyApp,
          web_app: "my_app",
          web_namespace: MyApp.Web,
          web_path: "my_app"
        } <- remove_instable_values(res)
      )
    end

    test "with --app -> sets the app" do
      res = MaxoApp.unit_test_project("my_app --app=other_app")

      auto_assert(
        %MaxoNew.Project{
          app: "other_app",
          app_mod: OtherApp,
          app_path: "my_app",
          app_test: "other_app_test",
          base_path: "my_app",
          binding: [
            adapter_config: [
              test: [
                username: "postgres",
                password: "postgres",
                hostname: "localhost",
                database:
                  {:literal, "\"other_app_test\#{System.get_env(\"MIX_TEST_PARTITION\")}\""},
                pool: Ecto.Adapters.SQL.Sandbox,
                pool_size: 10
              ],
              dev: [
                username: "postgres",
                password: "postgres",
                hostname: "localhost",
                database: "other_app_dev",
                stacktrace: true,
                show_sensitive_data_on_connection_error: true,
                pool_size: 10
              ],
              test_setup_all: "Ecto.Adapters.SQL.Sandbox.mode(OtherApp.Repo, :manual)",
              test_setup: """
                  pid = Ecto.Adapters.SQL.Sandbox.start_owner!(OtherApp.Repo, shared: not tags[:async])
                  on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)\
              """,
              prod_variables: """
              database_url =
                System.get_env("DATABASE_URL") ||
                  raise \"""
                  environment variable DATABASE_URL is missing.
                  For example: ecto://USER:PASS@HOST/DATABASE
                  \"""

              maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

              """,
              prod_config: """
              # ssl: true,
              url: database_url,
              pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
              socket_options: maybe_ipv6
              """
            ],
            lv_signing_salt: "XAYEV79U",
            signing_salt: "eJEULGk4",
            secret_key_base_test:
              "0FFfOkBrw43N3lvFcJLh7e1dweRG9SLbSAkhopP/JdedPgwtpU+Y6JcG2JSsQ/8r",
            secret_key_base_dev:
              "N0TMlBsoiJnRILN4Fbwp7NN5PeuzjaxKrszSmvU+xYoXIarqbIuaqRRI2XKqXsxp",
            app_name: "other_app",
            app_module: "OtherApp",
            root_app_name: "other_app",
            root_app_module: "OtherApp",
            lib_web_name: "other_app/web",
            web_app_name: "other_app",
            endpoint_module: "OtherApp.Web.Endpoint",
            web_namespace: "OtherApp.Web",
            phoenix_dep: "{:phoenix, \"~> 1.7.2\"}",
            phoenix_dep_umbrella_root: "{:phoenix, \"~> 1.7.2\"}",
            phoenix_js_path: "phoenix",
            phoenix_version: "1.7.2",
            pubsub_server: OtherApp.PubSub,
            in_umbrella: false,
            asset_builders: [:tailwind, :esbuild],
            javascript: true,
            css: true,
            mailer: true,
            ecto: true,
            html: true,
            live: true,
            live_comment: nil,
            dashboard: true,
            gettext: true,
            adapter_app: :postgrex,
            adapter_module: Ecto.Adapters.Postgres,
            generators: nil,
            namespaced?: false,
            dev: false
          ],
          lib_web_name: "other_app/web",
          opts: [app: "other_app"],
          project_path: "my_app",
          root_app: "other_app",
          root_mod: OtherApp,
          web_app: "other_app",
          web_namespace: OtherApp.Web,
          web_path: "my_app"
        } <- remove_instable_values(res)
      )

      res = MaxoApp.unit_test_project("my_app --app=BIGAPP")

      auto_assert(
        %MaxoNew.Project{
          app: "BIGAPP",
          app_mod: BIGAPP,
          app_path: "my_app",
          app_test: "BIGAPP_test",
          base_path: "my_app",
          binding: [
            adapter_config: [
              test: [
                username: "postgres",
                password: "postgres",
                hostname: "localhost",
                database: {:literal, "\"bigapp_test\#{System.get_env(\"MIX_TEST_PARTITION\")}\""},
                pool: Ecto.Adapters.SQL.Sandbox,
                pool_size: 10
              ],
              dev: [
                username: "postgres",
                password: "postgres",
                hostname: "localhost",
                database: "bigapp_dev",
                stacktrace: true,
                show_sensitive_data_on_connection_error: true,
                pool_size: 10
              ],
              test_setup_all: "Ecto.Adapters.SQL.Sandbox.mode(BIGAPP.Repo, :manual)",
              test_setup: """
                  pid = Ecto.Adapters.SQL.Sandbox.start_owner!(BIGAPP.Repo, shared: not tags[:async])
                  on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)\
              """,
              prod_variables: """
              database_url =
                System.get_env("DATABASE_URL") ||
                  raise \"""
                  environment variable DATABASE_URL is missing.
                  For example: ecto://USER:PASS@HOST/DATABASE
                  \"""

              maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

              """,
              prod_config: """
              # ssl: true,
              url: database_url,
              pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
              socket_options: maybe_ipv6
              """
            ],
            lv_signing_salt: "XAYEV79U",
            signing_salt: "eJEULGk4",
            secret_key_base_test:
              "0FFfOkBrw43N3lvFcJLh7e1dweRG9SLbSAkhopP/JdedPgwtpU+Y6JcG2JSsQ/8r",
            secret_key_base_dev:
              "N0TMlBsoiJnRILN4Fbwp7NN5PeuzjaxKrszSmvU+xYoXIarqbIuaqRRI2XKqXsxp",
            app_name: "BIGAPP",
            app_module: "BIGAPP",
            root_app_name: "BIGAPP",
            root_app_module: "BIGAPP",
            lib_web_name: "BIGAPP/web",
            web_app_name: "BIGAPP",
            endpoint_module: "BIGAPP.Web.Endpoint",
            web_namespace: "BIGAPP.Web",
            phoenix_dep: "{:phoenix, \"~> 1.7.2\"}",
            phoenix_dep_umbrella_root: "{:phoenix, \"~> 1.7.2\"}",
            phoenix_js_path: "phoenix",
            phoenix_version: "1.7.2",
            pubsub_server: BIGAPP.PubSub,
            in_umbrella: false,
            asset_builders: [:tailwind, :esbuild],
            javascript: true,
            css: true,
            mailer: true,
            ecto: true,
            html: true,
            live: true,
            live_comment: nil,
            dashboard: true,
            gettext: true,
            adapter_app: :postgrex,
            adapter_module: Ecto.Adapters.Postgres,
            generators: nil,
            namespaced?: false,
            dev: false
          ],
          lib_web_name: "BIGAPP/web",
          opts: [app: "BIGAPP"],
          project_path: "my_app",
          root_app: "BIGAPP",
          root_mod: BIGAPP,
          web_app: "BIGAPP",
          web_namespace: BIGAPP.Web,
          web_path: "my_app"
        } <- remove_instable_values(res)
      )
    end

    test "with --binary-id -> sets binding.generators" do
      res = MaxoApp.unit_test_project("my_app --binary-id")

      auto_assert(
        [binary_id: true] <- remove_instable_values(res).binding |> Keyword.get(:generators)
      )

      res = MaxoApp.unit_test_project("my_app --binary-id=false")

      auto_assert(
        [binary_id: false] <- remove_instable_values(res).binding |> Keyword.get(:generators)
      )
    end

    test "with --gettext -> sets binding.gettext" do
      res = MaxoApp.unit_test_project("my_app --gettext=false")
      auto_assert(false <- remove_instable_values(res).binding |> Keyword.get(:gettext))

      res = MaxoApp.unit_test_project("my_app --gettext")
      auto_assert(true <- remove_instable_values(res).binding |> Keyword.get(:gettext))
    end
  end

  describe "unit_test_args" do
    test "just path" do
      ExUnit.CaptureIO.capture_io(fn ->
        res = MaxoApp.unit_test_args("my_app")

        auto_assert(
          [
            "/my_app/lib/my_app/web/components/core_components.ex",
            "/my_app/lib/my_app/web/router.ex",
            "/my_app/lib/my_app/web/controllers/error_html.ex",
            "/my_app/lib/my_app/web/components/layouts.ex",
            "/my_app/lib/my_app/web/controllers/error_json_test.exs",
            "/my_app/lib/my_app/web/controllers/error_json.ex",
            "/my_app/lib/my_app/web/controllers",
            "/my_app/lib/my_app/web/components/layouts",
            "/my_app/lib/my_app/web/components/layouts/app.html.heex",
            "/my_app/lib/my_app/web/components",
            "/my_app/lib/my_app/web/components/layouts/root.html.heex",
            "/my_app/lib/my_app/web/controllers/error_html_test.exs",
            "/my_app/lib/my_app/web/gettext.ex",
            "/my_app/lib/my_app/web/telemetry.ex",
            "/my_app/lib/my_app/web/endpoint.ex"
          ] <- Virtfs.tree!(res.fs, "/my_app/lib/my_app/web")
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
      :secret_key_base_dev,
      "N0TMlBsoiJnRILN4Fbwp7NN5PeuzjaxKrszSmvU+xYoXIarqbIuaqRRI2XKqXsxp"
    )
    |> Keyword.put(
      :secret_key_base_test,
      "0FFfOkBrw43N3lvFcJLh7e1dweRG9SLbSAkhopP/JdedPgwtpU+Y6JcG2JSsQ/8r"
    )
    |> Keyword.put(:signing_salt, "eJEULGk4")
    |> Keyword.put(:lv_signing_salt, "XAYEV79U")
    |> clean_adapter_config()
  end

  defp clean_adapter_config(binding) do
    adapter_config = Keyword.get(binding, :adapter_config)
    test = Keyword.get(adapter_config, :test)
    adapter_config = Keyword.put(adapter_config, :test, test)
    Keyword.put(binding, :adapter_config, adapter_config)
  end
end
