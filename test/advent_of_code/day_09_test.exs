defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  @input """
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """

  test "part1" do
    114 = part1(@input)
  end

  test "part2" do
    2 = part2(@input)
  end
end
