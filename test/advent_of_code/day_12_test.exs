defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  @input """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
  """

  test "part1" do
    21 = part1(@input)
  end

  test "part2" do
    525_152 = part2(@input)
  end
end
