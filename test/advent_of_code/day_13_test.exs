defmodule AdventOfCode.Day13Test do
  use ExUnit.Case

  import AdventOfCode.Day13

  @input """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#

  """

  test "part1" do
    405 = part1(@input)
  end

  test "part2" do
    400 = part2(@input)
  end
end
