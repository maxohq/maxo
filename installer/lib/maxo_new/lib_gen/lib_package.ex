defmodule MaxoNew.LibGen.LibPackage do
  @moduledoc false
  use MaxoNew.LibGen.Generator
  alias MaxoNew.LibGen.LibDesc

  template(:new, [
    {
      :eex,
      :project,
      "lib_normal/config/config.exs": "config/config.exs",
      "lib_normal/lib/lib_name.ex": "lib/:app.ex",
      "lib_normal/lib/lib_name_test.exs": "lib/:app_test.exs",
      "lib_normal/lib/lib_name/application.ex": "lib/:app/application.ex",
      "lib_normal/lib/test_helper.exs": "lib/test_helper.exs",
      "lib_normal/mix.exs": "mix.exs",
      "lib_normal/README.md": "README.md",
      "lib_normal/CHANGELOG.md": "CHANGELOG.md",
      "lib_normal/Makefile": "Makefile",
      "lib_normal/formatter.exs": ".formatter.exs",
      "lib_normal/gitignore": ".gitignore",
      "lib_normal/test/test_helper.exs": "test/test_helper.exs"
    }
  ])

  template(:example, [
    {
      :eex,
      :project,
      "lib_normal/examples/example.exs": "examples/example.exs",
      "lib_normal/examples/example.tape": "examples/example.tape",
      "lib_normal/examples/gen_tape.exs": "examples/gen_tape.exs"
    }
  ])

  template(:github, [
    {
      :eex,
      :project,
      "lib_normal/github/workflows/ci.yml": ".github/workflows/ci.yml"
    }
  ])

  template(:bin, [
    {
      :eex,
      :project,
      "lib_normal/bin/test": "bin/test",
      "lib_normal/bin/test_iex": "bin/test_iex",
      "lib_normal/bin/setup": "bin/setup"
    }
  ])

  def generate(%LibDesc{} = project) do
    copy_from(project, __MODULE__, :new)
    copy_from(project, __MODULE__, :github)
    copy_from(project, __MODULE__, :example)
    copy_from(project, __MODULE__, :bin)
    project
  end

  def prepare_project(%LibDesc{app: app} = project) when not is_nil(app) do
    %LibDesc{project | project_path: project.base_path}
    |> put_bindings()
  end

  # we need 2 bindings
  # -  @app_name
  # -  @app_module
  def put_bindings(%LibDesc{app: app, app_mod: app_mod} = p) do
    p
    |> Map.put(:binding,
      app_name: app,
      app_module: inspect(app_mod),
      today: Date.utc_today() |> Date.to_string()
    )
  end
end
