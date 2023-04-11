defmodule MaxoNew.LibGen.LibDesc do
  @moduledoc false
  alias MaxoNew.LibGen.LibDesc
  alias MaxoNew.Virtfs

  defstruct base_path: nil,
            app: nil,
            app_test: nil,
            app_mod: nil,
            app_path: nil,
            project_path: nil,
            binding: [],
            opts: nil,
            fs: nil

  def new(project_path, opts) do
    app = opts[:app] || Path.basename(project_path)
    app_mod = Module.concat([opts[:module] || Macro.camelize(app)])
    {:ok, fs} = Virtfs.start_link()

    %LibDesc{
      base_path: project_path,
      app: app,
      app_test: "#{app}_test",
      app_mod: app_mod,
      opts: opts,
      fs: fs
    }
  end

  def verbose?(%LibDesc{opts: opts}) do
    Keyword.get(opts, :verbose, false)
  end

  def join_path(%LibDesc{} = lib_desc, location, path)
      when location in [:project, :app] do
    lib_desc
    |> Map.fetch!(:"#{location}_path")
    |> Path.join(path)
    |> expand_path_with_bindings(lib_desc)
  end

  defp expand_path_with_bindings(path, %LibDesc{} = lib_desc) do
    Regex.replace(Regex.recompile!(~r/:[a-zA-Z0-9_]+/), path, fn ":" <> key, _ ->
      lib_desc |> Map.fetch!(:"#{key}") |> to_string()
    end)
  end
end
