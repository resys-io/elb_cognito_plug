defmodule ELBPlugTest do
  use ExUnit.Case
  doctest ELBPlug

  test "greets the world" do
    assert ELBPlug.hello() == :world
  end
end
