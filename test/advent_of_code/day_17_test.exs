defmodule AdventOfCode.Day17Test do
  use ExUnit.Case

  import AdventOfCode.Day17

  @input """
  2413432311323
  3215453535623
  3255245654254
  3446585845452
  4546657867536
  1438598798454
  4457876987766
  3637877979653
  4654967986887
  4564679986453
  1224686865563
  2546548887735
  4322674655533
  """

  test "part1" do
    102 = part1(@input)
  end

  test "part2" do
    94 = part2(@input)

    71 =
      part2("""
      111111111111
      999999999991
      999999999991
      999999999991
      999999999991
      """)
  end
end
