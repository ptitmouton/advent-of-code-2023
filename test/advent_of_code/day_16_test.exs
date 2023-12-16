defmodule AdventOfCode.Day16Test do
  use ExUnit.Case

  import AdventOfCode.Day16

  @input """
    .|...\\....
    |.-.\\.....
    .....|-...
    ........|.
    ..........
    .........\\
    ..../.\\\\..
    .-.-/..|..
    .|....-|.\\
    ..//.|....
  """

  test "part1" do
    46 = part1(@input)
  end

  test "part2" do
    51 = part2(@input)
  end
end
