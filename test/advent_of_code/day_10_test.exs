defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  import AdventOfCode.Day10

  test "part1" do
    input1 = """
      .....
      .S-7.
      .|.|.
      .L-J.
      .....
    """

    input2 = """
      ..F7.
      .FJ|.
      SJ.L7
      |F--J
      LJ...
    """

    4 = part1(input1)
    8 = part1(input2)
  end

  test "part2" do
    input1 = """
      ...........
      .S-------7.
      .|F-----7|.
      .||.....||.
      .||.....||.
      .|L-7.F-J|.
      .|..|.|..|.
      .L--J.L--J.
      ...........
    """

    input2 = """
      ..........
      .S------7.
      .|F----7|.
      .||OOOO||.
      .||OOOO||.
      .|L-7F-J|.
      .|II||II|.
      .L--JL--J.
      ..........
    """

    input3 = """
      .F----7F7F7F7F-7....
      .|F--7||||||||FJ....
      .||.FJ||||||||L7....
      FJL7L7LJLJ||LJ.L-7..
      L--J.L7...LJS7F-7L7.
      ....F-J..F7FJ|L7L7L7
      ....L7.F7||L7|.L7L7|
      .....|FJLJ|FJ|F7|.LJ
      ....FJL-7.||.||||...
      ....L---J.LJ.LJLJ...
    """

    4 = part2(input1)
    4 = part2(input2)
    8 = part2(input3)
  end
end
