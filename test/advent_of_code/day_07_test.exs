defmodule AdventOfCode.Day07Test do
  use ExUnit.Case

  import AdventOfCode.Day07

  @input """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  test "part1" do
    6440 = part1(@input)
  end

  test "part2" do
    5905 = part2(@input)
  end
end
