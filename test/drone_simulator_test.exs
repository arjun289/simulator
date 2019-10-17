defmodule DroneSimulatorTest do
  use ExUnit.Case
  doctest DroneSimulator

  test "greets the world" do
    assert DroneSimulator.hello() == :world
  end
end
