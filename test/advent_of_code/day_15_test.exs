defmodule AdventOfCode.Day15Test do
  use ExUnit.Case

  import AdventOfCode.Day15

  @input "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

  test "part1" do
    1320 = part1(@input)
  end

  test "part2" do
    145 = part2(@input)
  end
end
