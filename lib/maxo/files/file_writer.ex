defmodule Maxo.Files.FileWriter do
  use Maxo.FunServer
  alias Maxo.Files.State
  @init_state %State{}

  def start_link(), do: start_link(@init_state)
  def start_link(state), do: GenServer.start_link(__MODULE__, state)

  @impl true
  def init(state = %State{}), do: {:ok, state}

  ## API
  def put(pid, line), do: sync(pid, handle_put(line))
  def put(pid, line, indent), do: sync(pid, handle_put(line, indent))
  def content(pid), do: sync(pid, handle_content())
  def reset(pid), do: sync(pid, handle_reset())

  ## Dumping
  def dump(pid, path), do: sync(pid, handle_dump(path))
  def set_dumper(pid, dumper), do: sync(pid, handle_set_dumper(dumper))

  ## Indenting
  def get_indent(pid), do: sync(pid, handle_get_indent())
  def indent_up(pid, amount \\ 2), do: sync(pid, handle_indent_up(amount))
  def indent_down(pid, amount \\ 2), do: sync(pid, handle_indent_down(amount))
  def indented(pid, fun), do: indented(pid, fun, 2)
  def indented(pid, amount, fun) when is_number(amount), do: indented(pid, fun, amount)

  def indented(pid, fun, amount) do
    indent_up(pid, amount)
    fun.()
    indent_down(pid, amount)
  end

  ### FunServer functions
  defp handle_put(line) do
    fn _, %State{} = state ->
      {:reply, :ok, _add_line(state, line, state.indent)}
    end
  end

  defp handle_put(line, indent) do
    fn _, %State{} = state ->
      {:reply, :ok, _add_line(state, line, indent)}
    end
  end

  defp handle_get_indent() do
    fn _, %State{} = state -> {:reply, state.indent, state} end
  end

  defp handle_indent_up(amount) do
    fn _, %State{} = state ->
      state = _put_indent(state, state.indent + amount)
      {:reply, :ok, state}
    end
  end

  defp handle_indent_down(amount) do
    fn _, %State{} = state ->
      state = _put_indent(state, max(state.indent - amount, 0))
      {:reply, :ok, state}
    end
  end

  defp handle_content() do
    fn _, %State{} = state -> {:reply, _to_content(state), state} end
  end

  defp handle_reset() do
    fn _, %State{} -> {:reply, :ok, @init_state} end
  end

  defp handle_dump(path) do
    fn _, %State{} = state -> {:reply, _to_dump(state, path), state} end
  end

  defp handle_set_dumper(dumper) do
    fn _, %State{} = state ->
      state = %State{state | dumper: dumper}
      {:reply, :ok, state}
    end
  end

  ###
  ### Internal helpers
  ###
  defp sync(server, handler), do: Maxo.FunServer.sync(server, handler)

  defp _add_line(%State{} = state, line, indent) do
    %State{state | lines: [_indented_line(line, indent) | state.lines]}
  end

  defp _put_indent(%State{} = state, indent) do
    %State{state | indent: indent}
  end

  defp _indented_line(line, indent) do
    ~s|#{String.duplicate(" ", indent)}#{line}|
  end

  defp _to_content(%State{} = state) do
    state.lines |> Enum.reverse() |> Enum.join("\n")
  end

  defp _to_dump(%State{dumper: {mod, fun}} = state, path) do
    apply(mod, fun, [path, _to_content(state)])
  end

  defp _to_dump(%State{dumper: dumper} = state, path) when is_function(dumper, 2) do
    dumper.(path, _to_content(state))
  end
end
