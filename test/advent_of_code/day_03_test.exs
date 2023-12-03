defmodule AdventOfCode.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Day03
  @input """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """

  test "part1" do

    result = part1(@input)

    4361 = result
  end

  test "part2" do
    result = part2(@input)

    467835 = result
  end
end
