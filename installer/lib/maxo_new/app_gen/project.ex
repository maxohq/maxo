defmodule MaxoNew.Project do
  @moduledoc false
  alias MaxoNew.Project
  alias MaxoNew.Virtfs

  defstruct base_path: nil,
            app: nil,
            app_test: nil,
            app_mod: nil,
            app_path: nil,
            lib_web_name: nil,
            root_app: nil,
            root_mod: nil,
            project_path: nil,
            web_app: nil,
            web_namespace: nil,
            web_path: nil,
            opts: :unset,
            in_umbrella?: false,
            binding: [],
            generators: [],
            fs: nil

  def new(project_path, opts) do
    app = opts[:app] || Path.basename(project_path)
    app_mod = Module.concat([opts[:module] || Macro.camelize(app)])
    {:ok, fs} = Virtfs.start_link()

    %Project{
      base_path: project_path,
      app: app,
      app_test: "#{app}_test",
      app_mod: app_mod,
      root_app: app,
      root_mod: app_mod,
      opts: opts,
      fs: fs
    }
  end

  def ecto?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :ecto)
  end

  def html?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :html)
  end

  def gettext?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :gettext)
  end

  def live?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :live)
  end

  def dashboard?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :dashboard)
  end

  def javascript?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :javascript)
  end

  def css?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :css)
  end

  def mailer?(%Project{binding: binding}) do
    Keyword.fetch!(binding, :mailer)
  end

  def verbose?(%Project{opts: opts}) do
    Keyword.get(opts, :verbose, false)
  end

  def join_path(%Project{} = project, location, path)
      when location in [:project, :app, :web] do
    project
    |> Map.fetch!(:"#{location}_path")
    |> Path.join(path)
    |> expand_path_with_bindings(project)
  end

  defp expand_path_with_bindings(path, %Project{} = project) do
    Regex.replace(Regex.recompile!(~r/:[a-zA-Z0-9_]+/), path, fn ":" <> key, _ ->
      project |> Map.fetch!(:"#{key}") |> to_string()
    end)
  end
end
