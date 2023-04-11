defmodule <%= @app_module %>Test do
  use ExUnit.Case
  use MnemeDefaults

  test "greeting" do
    auto_assert(<%= @app_module %>.greeting())
  end
end
