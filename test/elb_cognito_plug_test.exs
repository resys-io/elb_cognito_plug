defmodule ELBCognitoPlugTest do
  use ExUnit.Case
  doctest ELBCognitoPlug

  test "greets the world" do
    assert ELBCognitoPlug.hello() == :world
  end
end
