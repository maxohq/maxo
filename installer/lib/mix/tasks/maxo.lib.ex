defmodule Mix.Tasks.Maxo.Lib do
  @moduledoc """
  Creates a new Maxo package.

  It expects the path of the project as an argument.

      $ mix maxo.lib PATH

  A project at the given PATH will be created. The
  application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.

  ## Options

    * `--app` - the name of the OTP application

    * `--module` - the name of the base module in
      the generated skeleton

    * `--verbose` - use verbose output

    * `-v`, `--version` - prints the Phoenix installer version
  """
  use Mix.Task
  alias MaxoNew.LibGen.LibDesc
  alias MaxoNew.LibGen.LibPackage

  @version Mix.Project.config()[:version]
  @shortdoc "Creates a new  Elixir package."

  @switches [
    verbose: :boolean
  ]

  @impl true
  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("Maxo Lib v#{@version}")
  end

  def run(argv) do
    case OptionParser.parse!(argv, strict: @switches) do
      {_opts, []} -> Mix.Tasks.Help.run(["maxo.lib"])
      {opts, [base_path | _]} -> generate(base_path, LibPackage, :project_path, opts)
    end
  end

  @doc false
  def run(argv, generator, path) do
    case OptionParser.parse!(argv, strict: @switches) do
      {_opts, []} -> Mix.Tasks.Help.run(["maxo.lib"])
      {opts, [base_path | _]} -> generate(base_path, generator, path, opts)
    end
  end

  ###
  ### Unit Test functions
  ###
  def unit_test_args(command) do
    argv = String.split(command, " ")

    case OptionParser.parse!(argv, strict: @switches) do
      {_opts, []} -> Mix.Tasks.Help.run(["maxo.lib"])
      {opts, [base_path | _]} -> do_generation(base_path, LibPackage, :project_path, opts)
    end
  end

  def unit_test_project(command) do
    argv = String.split(command, " ")

    case OptionParser.parse!(argv, strict: @switches) do
      {_opts, []} ->
        Mix.Tasks.Help.run(["maxo.lib"])

      {opts, [base_path | _]} ->
        do_full_project_struct(base_path, LibPackage, :project_path, opts)
    end
  end

  # smaller functions, so we can test them in isolation through the `unit_test_...` functions
  defp generate(base_path, generator, path, opts) do
    do_generation(base_path, generator, path, opts)
    |> dump_to_base_path(base_path)
  end

  defp do_generation(base_path, generator, path, opts) do
    do_full_project_struct(base_path, generator, path, opts)
    |> validate_project(path)
    |> generator.generate()
  end

  defp do_full_project_struct(base_path, generator, _path, opts) do
    base_path
    |> LibDesc.new(opts)
    |> generator.prepare_project()
  end

  defp validate_project(%LibDesc{opts: opts} = project, path) do
    check_app_name!(project.app, !!opts[:app])
    check_directory_existence!(Map.fetch!(project, path))
    check_module_name_validity!(project.app_mod)
    check_module_name_availability!(project.app_mod)

    project
  end

  defp dump_to_base_path(project, _base_path) do
    MaxoNew.Virtfs.dump(project.fs, ".")
    project
  end

  ## Helpers

  defp check_app_name!(name, from_app_flag) do
    unless name =~ Regex.recompile!(~r/^[a-z][\w_]*$/) do
      extra =
        if !from_app_flag do
          ". The application name is inferred from the path, if you'd like to " <>
            "explicitly name the application then use the `--app APP` option."
        else
          ""
        end

      Mix.raise(
        "Application name must start with a letter and have only lowercase " <>
          "letters, numbers and underscore, got: #{inspect(name)}" <> extra
      )
    end
  end

  defp check_module_name_validity!(name) do
    unless inspect(name) =~ Regex.recompile!(~r/^[A-Z]\w*(\.[A-Z]\w*)*$/) do
      Mix.raise(
        "Module name must be a valid Elixir alias (for example: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  defp check_module_name_availability!(name) do
    [name]
    |> Module.concat()
    |> Module.split()
    |> Enum.reduce([], fn name, acc ->
      mod = Module.concat([Elixir, name | acc])

      if Code.ensure_loaded?(mod) do
        Mix.raise("Module name #{inspect(mod)} is already taken, please choose another name")
      else
        [name | acc]
      end
    end)
  end

  defp check_directory_existence!(path) do
    if File.dir?(path) and
         not Mix.shell().yes?(
           "The directory #{path} already exists. Are you sure you want to continue?"
         ) do
      Mix.raise("Please select another directory for installation.")
    end
  end
end
