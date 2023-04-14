defmodule MaxoNew.Single do
  @moduledoc false
  use MaxoNew.Generator
  alias MaxoNew.Project

  template(:new, [
    {:eex, :project,
     "app_single/config/config.exs": "config/config.exs",
     "app_single/config/dev.exs": "config/dev.exs",
     "app_single/config/prod.exs": "config/prod.exs",
     "app_single/config/runtime.exs": "config/runtime.exs",
     "app_single/config/test.exs": "config/test.exs",
     "app_single/lib/app_name/application.ex": "lib/:app/application.ex",
     "app_single/lib/app_name.ex": "lib/:app.ex",
     "app_web/controllers/error_json.ex": "lib/:app/web/controllers/error_json.ex",
     "app_web/endpoint.ex": "lib/:app/web/endpoint.ex",
     "app_web/router.ex": "lib/:app/web/router.ex",
     "app_web/telemetry.ex": "lib/:app/web/telemetry.ex",
     "app_single/lib/app_name_web.ex": "lib/:lib_web_name.ex",
     "app_single/mix.exs": "mix.exs",
     "app_single/README.md": "README.md",
     "app_single/formatter.exs": ".formatter.exs",
     "app_single/gitignore": ".gitignore",
     "app_test/support/conn_case.ex": "test/support/conn_case.ex",
     "app_single/test/test_helper.exs": "test/test_helper.exs",
     "app_single/lib/test_helper.exs": "lib/test_helper.exs",
     "app_test/controllers/error_json_test.exs": "lib/:app/web/controllers/error_json_test.exs"}
  ])

  template(:gettext, [
    {:eex, :project,
     "app_gettext/gettext.ex": "lib/:app/web/gettext.ex",
     "app_gettext/en/LC_MESSAGES/errors.po": "priv/gettext/en/LC_MESSAGES/errors.po",
     "app_gettext/errors.pot": "priv/gettext/errors.pot"}
  ])

  template(:html, [
    {:eex, :project,
     "app_web/controllers/error_html.ex": "lib/:app/web/controllers/error_html.ex",
     "app_test/controllers/error_html_test.exs": "lib/:app/web/controllers/error_html_test.exs",
     "app_web/components/core_components.ex": "lib/:app/web/components/core_components.ex",
     "app_web/page/page_controller.ex": "lib/:app/page/page_controller.ex",
     "app_web/page/page_html.ex": "lib/:app/page/page_html.ex",
     "app_web/page/page_html/home.html.heex": "lib/:app/page/page_html/home.html.heex",
     "app_web/page/page_controller_test.exs": "lib/:app/page/page_controller_test.exs",
     "app_web/components/layouts/root.html.heex": "lib/:app/web/components/layouts/root.html.heex",
     "app_web/components/layouts/app.html.heex": "lib/:app/web/components/layouts/app.html.heex",
     "app_web/components/layouts.ex": "lib/:app/web/components/layouts.ex"},
    {:eex, :web, "app_assets/logo.svg": "priv/static/images/logo.svg"}
  ])

  template(:ecto, [
    {:eex, :app,
     "app_ecto/repo.ex": "lib/:app/repo.ex",
     "app_ecto/formatter.exs": "priv/repo/migrations/.formatter.exs",
     "app_ecto/seeds.exs": "priv/repo/seeds.exs",
     "app_ecto/data_case.ex": "test/support/data_case.ex"},
    {:keep, :app, "app_ecto/priv/repo/migrations": "priv/repo/migrations"}
  ])

  template(:css, [
    {:eex, :web,
     "app_assets/app.css": "assets/css/app.css",
     "app_assets/tailwind.config.js": "assets/tailwind.config.js"}
    # {:eex, :web,
    #  "app_assets/heroicons/LICENSE.md": "assets/vendor/heroicons/LICENSE.md",
    #  "app_assets/heroicons/UPGRADE.md": "assets/vendor/heroicons/UPGRADE.md"}
    # {:zip, :web, "app_assets/heroicons/optimized.zip": "assets/vendor/heroicons/optimized"}
  ])

  template(:js, [
    {:eex, :web,
     "app_assets/app.js": "assets/js/app.js", "app_assets/topbar.js": "assets/vendor/topbar.js"}
  ])

  template(:no_js, [
    {:text, :web, "app_static/app.js": "priv/static/assets/app.js"}
  ])

  template(:no_css, [
    {:text, :web,
     "app_static/app.css": "priv/static/assets/app.css",
     "app_static/home.css": "priv/static/assets/home.css"}
  ])

  template(:static, [
    {:text, :web,
     "app_static/robots.txt": "priv/static/robots.txt",
     "app_static/favicon.ico": "priv/static/favicon.ico"}
  ])

  template(:mailer, [
    {:eex, :app, "app_mailer/lib/app_name/mailer.ex": "lib/:app/mailer.ex"}
  ])

  def prepare_project(%Project{app: app} = project) when not is_nil(app) do
    %Project{project | project_path: project.base_path}
    |> put_app()
    |> put_root_app()
    |> put_web_app()
  end

  defp put_app(%Project{base_path: base_path} = project) do
    %Project{project | in_umbrella?: false, app_path: base_path}
  end

  defp put_root_app(%Project{app: app, opts: opts} = project) do
    %Project{
      project
      | root_app: app,
        root_mod: Module.concat([opts[:module] || Macro.camelize(app)])
    }
  end

  defp put_web_app(%Project{app: app} = project) do
    %Project{
      project
      | web_app: app,
        lib_web_name: "#{app}/web",
        web_namespace: Module.concat(["#{project.root_mod}.Web"]),
        web_path: project.project_path
    }
  end

  def generate(%Project{} = project) do
    copy_from(project, __MODULE__, :new)

    if Project.ecto?(project), do: gen_ecto(project)
    if Project.html?(project), do: gen_html(project)
    if Project.mailer?(project), do: gen_mailer(project)
    if Project.gettext?(project), do: gen_gettext(project)

    gen_assets(project)
    project
  end

  def gen_html(project) do
    copy_from(project, __MODULE__, :html)
  end

  def gen_gettext(project) do
    copy_from(project, __MODULE__, :gettext)
  end

  def gen_ecto(project) do
    copy_from(project, __MODULE__, :ecto)
    gen_ecto_config(project)
  end

  def gen_assets(%Project{} = project) do
    javascript? = Project.javascript?(project)
    css? = Project.css?(project)
    html? = Project.html?(project)

    copy_from(project, __MODULE__, :static)

    if html? or javascript? do
      command = if javascript?, do: :js, else: :no_js
      copy_from(project, __MODULE__, command)
    end

    if html? or css? do
      command = if css?, do: :css, else: :no_css
      copy_from(project, __MODULE__, command)
    end
  end

  def gen_mailer(%Project{} = project) do
    copy_from(project, __MODULE__, :mailer)
  end
end
