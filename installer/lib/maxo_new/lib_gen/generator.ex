defmodule MaxoNew.LibGen.Generator do
  @moduledoc false
  import MaxoNew.Virtfs.Mix.Generator
  alias MaxoNew.LibGen.LibDesc
  alias MaxoNew.Virtfs

  @callback prepare_project(LibDesc.t()) :: LibDesc.t()
  @callback generate(LibDesc.t()) :: LibDesc.t()

  defmacro __using__(_env) do
    quote do
      @behaviour unquote(__MODULE__)
      import MaxoNew.Virtfs.Mix.Generator
      import unquote(__MODULE__)
      alias MaxoNew.Virtfs
      Module.register_attribute(__MODULE__, :templates, accumulate: true)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    root = Path.expand("../../../templates", __DIR__)

    # some
    templates_ast =
      for {name, mappings} <- Module.get_attribute(env.module, :templates) do
        for {format, _proj_location, files} <- mappings,
            format != :keep,
            {source, _target} <- files,
            source = to_string(source) do
          path = Path.join(root, source)

          if format in [:config, :prod_config, :eex] do
            compiled = EEx.compile_file(path)

            quote do
              @external_resource unquote(path)
              @file unquote(path)
              def render(unquote(name), unquote(source), var!(assigns))
                  when is_list(var!(assigns)),
                  do: unquote(compiled)
            end
          else
            quote do
              @external_resource unquote(path)
              def render(unquote(name), unquote(source), _assigns), do: unquote(File.read!(path))
            end
          end
        end
      end

    quote do
      unquote(templates_ast)
      def template_files(name), do: Keyword.fetch!(@templates, name)
    end
  end

  defmacro template(name, mappings) do
    quote do
      @templates {unquote(name), unquote(mappings)}
    end
  end

  def copy_from(%LibDesc{} = lib_desc, mod, name) when is_atom(name) do
    mapping = mod.template_files(name)
    fs = lib_desc.fs

    for {format, project_location, files} <- mapping,
        {source, target_path} <- files,
        source = to_string(source) do
      target = LibDesc.join_path(lib_desc, project_location, target_path)

      cond do
        format == :keep ->
          Virtfs.mkdir_p!(fs, target)

        format == :zip ->
          parent_dir = Path.dirname(target)
          Mix.shell().info([:green, "* extracting ", :reset, Path.relative_to_cwd(target)])

          Virtfs.mkdir_p!(fs, parent_dir)
          zip_contents = mod.render(name, source, lib_desc.binding)
          {:ok, zip} = :zip.zip_open(zip_contents, [:memory])
          {:ok, files} = :zip.zip_get(zip)

          Enum.map(files, fn {path, contents} ->
            full_path = Path.join(parent_dir, path)
            Virtfs.mkdir_p!(fs, Path.dirname(full_path))
            Virtfs.write!(fs, full_path, contents)
          end)

        format in [:text, :eex] ->
          create_file(fs, target, mod.render(name, source, lib_desc.binding))
      end
    end
  end
end
