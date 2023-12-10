defmodule AdventOfCode.Day09 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_history_line/1)
    |> Enum.map(&get_next_prediction/1)
    |> Enum.reduce(&(&1 + &2))
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_history_line/1)
    |> Enum.map(&get_previous_prediction/1)
    |> Enum.reduce(&(&1 + &2))
  end

  defp get_next_prediction([n | _] = values) when is_integer(n),
    do: get_next_prediction([values])

  defp get_next_prediction([values]),
    do: get_next_prediction([create_next_line(values) | [values]])

  defp get_next_prediction([current_line | _] = value_lines) do
    if Enum.all?(current_line, &(&1 == 0)) do
      value_lines
      |> Enum.reduce([], fn
        line, [] ->
          [[0 | line]]

        line, [[bottom | _] | _] = results ->
          next = List.last(line)

          [
            [bottom + next | Enum.reverse(line)] | results
          ]
      end)
      |> List.first()
      |> List.first()
    else
      get_next_prediction([create_next_line(current_line) | value_lines])
    end
  end

  defp get_previous_prediction([n | _] = values) when is_integer(n),
    do: get_previous_prediction([values])

  defp get_previous_prediction([values]),
    do: get_previous_prediction([create_next_line(values) | [values]])

  defp get_previous_prediction([current_line | _] = value_lines) do
    if Enum.all?(current_line, &(&1 == 0)) do
      value_lines
      |> Enum.reduce([], fn
        line, [] ->
          [[0 | line]]

        [next | _] = line, [[bottom | _] | _] = results ->
          [
            [next - bottom | line] | results
          ]
      end)
      |> List.first()
      |> List.first()
    else
      get_previous_prediction([create_next_line(current_line) | value_lines])
    end
  end

  defp create_next_line(value_line) do
    value_line
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {_, index} when index == length(value_line) - 1 -> []
      {value, i} -> [Enum.at(value_line, i + 1) - value]
    end)
  end

  defp parse_history_line(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
