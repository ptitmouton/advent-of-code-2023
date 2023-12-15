defmodule AdventOfCode.Day14 do
  def part1(input) do
    input
    |> parse_map()
    |> tilt_north()
    |> weigh_rocks()
  end

  def part2(input) do
    map =
      input
      |> parse_map()

    cycle(map, find_repetition(map), 0)
    |> weigh_rocks()
  end

  defp find_repetition(map), do: 0..1000 |> Enum.to_list() |> find_repetition(map, %{})

  defp find_repetition([i | next_search], map, cache) do
    new_map = cycle_once(map)

    cache = Map.put(cache, map_cache_key(map), i)

    if start_point = Map.get(cache, map_cache_key(new_map)) do
      {start_point, i - start_point}
    else
      find_repetition(next_search, new_map, cache)
    end
  end

  defp cycle_once(map) do
    map
    |> tilt_north()
    |> turn_map()
    |> tilt_north()
    |> turn_map()
    |> tilt_north()
    |> turn_map()
    |> tilt_north()
    |> turn_map()
  end

  defp cycle(map, _, 1_000_000_000), do: map

  defp cycle(map, {repetition_start, repetition_length} = rep, n) when n == repetition_start do
    skip_cycles =
      1_000_000_000 - trunc(rem(1_000_000_000 - repetition_start, repetition_length + 1)) -
        repetition_start

    cycle(map, rep, n + skip_cycles)
  end

  defp cycle(map, rep, n) do
    cycle(cycle_once(map), rep, n + 1)
  end

  defp parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.trim_leading()
      |> String.to_charlist()
    end)
  end

  defp weigh_rocks(rows) do
    rows
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {row, i}, acc ->
      acc + Enum.count(row, &(&1 == ?O)) * i
    end)
  end

  defp turn_map([first_row | _] = rows) do
    0..(length(first_row) - 1)
    |> Enum.map(fn x ->
      rows
      |> Enum.map(&Enum.at(&1, x))
      |> Enum.reverse()
    end)
  end

  defp tilt_north([first_row | _] = rows) do
    columns =
      0..(length(first_row) - 1)
      |> Enum.map(fn x ->
        column = Enum.map(rows, &Enum.at(&1, x))

        Regex.replace(~r/(#?)(?:([O\.]+)(#?))/, to_string(column), fn _,
                                                                      first_fence,
                                                                      capture_rocks,
                                                                      last_fence ->
          first_fence <>
            (capture_rocks
             |> String.to_charlist()
             |> Enum.sort()
             |> Enum.reverse()
             |> to_string()) <> last_fence
        end)
        |> String.to_charlist()
      end)

    0..(length(rows) - 1)
    |> Enum.map(fn y ->
      Enum.map(columns, &Enum.at(&1, y))
    end)
  end

  defp map_cache_key(map), do: Enum.join(Enum.map(map, &to_string/1))
end
