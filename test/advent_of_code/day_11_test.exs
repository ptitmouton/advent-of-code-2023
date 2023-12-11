defmodule AdventOfCode.Day11Test do
  use ExUnit.Case

  import AdventOfCode.Day11

  @input """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
  """

  test "part1" do
    374 = part1(@input)
  end

  test "part2" do
    1030 = part2(@input, 10)
    8410 = part2(@input, 100)
  end
end
