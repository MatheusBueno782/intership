defmodule DatasetTest do
  use ExUnit.Case
  doctest Dataset

  test "greets the world" do
    assert Dataset.hello() == :world
  end
end
