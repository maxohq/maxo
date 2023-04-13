defmodule Maxo.Files.FileWriterTest do
  use ExUnit.Case, async: true
  use MnemeDefaults

  alias Maxo.Files.FileWriter, as: FW

  describe "full" do
    test "works" do
      {:ok, pid} = FW.start_link()
      FW.put(pid, ~s|## Hello|)
      FW.put(pid, ~s|defmodule Hey do|)

      FW.indented(pid, fn ->
        FW.put(pid, ~s|def hello do|)
        FW.indent_up(pid, 2)
        FW.put(pid, ~s|IO.puts "hello"|)
        FW.indent_down(pid, 2)
        FW.indented(pid, 2, fn -> FW.put(pid, ~s|IO.puts "hello"|) end)
        FW.put(pid, ~s|end|)
      end)

      FW.put(pid, ~s|end|)

      auto_assert(
        """
        ## Hello
        defmodule Hey do
          def hello do
            IO.puts "hello"
            IO.puts "hello"
          end
        end\
        """ <- FW.content(pid)
      )
    end
  end

  describe "set_dumper" do
    test "works with anon functions like: fn(path, content)" do
      {:ok, fs} = Virtfs.start_link()
      dumper = fn path, content -> Virtfs.write!(fs, path, content) end
      {:ok, pid} = FW.start_link()
      FW.set_dumper(pid, dumper)
      FW.put(pid, "a file")
      FW.dump(pid, "/some/file.ex")
      FW.dump(pid, "/some/file2.ex")
      auto_assert(["/some", "/some/file.ex", "/some/file2.ex"] <- Virtfs.tree!(fs, "/"))
      auto_assert("a file" <- Virtfs.read!(fs, "/some/file.ex"))
      auto_assert("a file" <- Virtfs.read!(fs, "/some/file2.ex"))
    end
  end
end
