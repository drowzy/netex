defmodule EchoControllerTest do
  use ExUnit.Case
  doctest EchoController

  test "greets the world" do
    assert EchoController.hello() == :world
  end
end
