defmodule AdventOfCode.Day13 do
  def part1(input) do
    input
    |> get_patterns()
    |> Enum.map(&parse_pattern/1)
    |> Enum.map(&find_pivot/1)
    |> Enum.map(fn
      {:vertical, n} -> n
      {:horizontal, n} -> n * 100
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> get_patterns()
    |> Enum.map(&parse_pattern/1)
    |> Enum.map(&find_pivot_with_smudge/1)
    |> Enum.map(fn
      {:vertical, n} -> n
      {:horizontal, n} -> n * 100
    end)
    |> Enum.sum()
  end

  defp find_pivot(pattern) do
    if vertical = find_perfect_column_pattern(pattern) do
      {:vertical, vertical}
    else
      horizontal =
        pattern
        |> as_columns()
        |> find_perfect_column_pattern()

      {:horizontal, horizontal}
    end
  end

  defp find_pivot_with_smudge(pattern) do
    if vertical = find_perfect_column_pattern_with_smudge(pattern) do
      {:vertical, vertical}
    else
      horizontal =
        pattern
        |> as_columns()
        |> find_perfect_column_pattern_with_smudge()

      {:horizontal, horizontal}
    end
  end

  defp as_columns([first_row | _] = rows) do
    0..(length(first_row) - 1)
    |> Enum.map(fn x ->
      Enum.map(0..(length(rows) - 1), fn y ->
        rows
        |> Enum.at(y)
        |> Enum.at(x)
      end)
    end)
  end

  defp find_perfect_column_pattern(input), do: find_perfect_column_pattern(input, 1)

  defp find_perfect_column_pattern([row | _], pivot) when pivot >= length(row),
    do: nil

  defp find_perfect_column_pattern(input, pivot) do
    if pivot_match?(input, pivot) do
      pivot
    else
      find_perfect_column_pattern(input, pivot + 1)
    end
  end

  defp pivot_match?(rows, pivot) do
    Enum.reduce(rows, true, fn
      row, true ->
        relevent_length =
          if pivot <= length(row) / 2 do
            pivot
          else
            length(row) - pivot
          end

        ray_left =
          Enum.slice(row, pivot - relevent_length, relevent_length)

        ray_right =
          Enum.slice(row, pivot, relevent_length)

        String.equivalent?(to_string(ray_left), to_string(Enum.reverse(ray_right)))

      _, false ->
        false
    end)
  end

  defp find_perfect_column_pattern_with_smudge(input),
    do: find_perfect_column_pattern_with_smudge(input, 1)

  defp find_perfect_column_pattern_with_smudge([row | _], pivot) when pivot >= length(row),
    do: nil

  defp find_perfect_column_pattern_with_smudge(input, pivot) do
    if pivot_match_with_smudge?(input, pivot) do
      pivot
    else
      find_perfect_column_pattern_with_smudge(input, pivot + 1)
    end
  end

  defp pivot_match_with_smudge?(rows, pivot) do
    Enum.reduce(rows, {true, 0}, fn
      row, {true, smudge} ->
        relevent_length =
          if pivot <= length(row) / 2 do
            pivot
          else
            length(row) - pivot
          end

        ray_left =
          Enum.slice(row, pivot - relevent_length, relevent_length)

        ray_right =
          Enum.slice(row, pivot, relevent_length)
          |> Enum.reverse()

        differences =
          ray_left
          |> Enum.with_index()
          |> Enum.filter(fn {l, i} ->
            l != Enum.at(ray_right, i)
          end)

        case length(differences) do
          0 when smudge < 2 ->
            {true, smudge}

          1 when smudge == 0 ->
            {true, 1}

          _ ->
            false
        end

      _, false ->
        false
    end)
    |> then(fn
      {true, 1} ->
        true

      _ ->
        false
    end)
  end

  defp get_patterns(input), do: String.split(input, "\n\n", trim: true)

  defp parse_pattern(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.trim_leading()
      |> String.to_charlist()
    end)
  end
end
