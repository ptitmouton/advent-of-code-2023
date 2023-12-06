defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  @input """
  Time:      7  15   30
  Distance:  9  40  200
  """

  test "part1" do
    288 = part1(@input)
  end

  test "part2" do
    71503 = part2(@input)
  end
end
