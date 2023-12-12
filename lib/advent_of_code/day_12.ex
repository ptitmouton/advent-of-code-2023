defmodule AdventOfCode.Day12 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim_leading/1)
    |> Enum.map(&parse_record/1)
    |> Task.async_stream(fn {springs, counts} ->
      get_possibilities({springs, counts})
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim_leading/1)
    |> Enum.map(&parse_record/1)
    |> Enum.map(&extend_record/1)
    |> Task.async_stream(fn {springs, counts} ->
      get_possibilities({springs, counts})
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp get_possibilities({"", []}), do: 1

  defp get_possibilities({springs, []}) do
    case String.match?(springs, ~r/#/) do
      true -> 0
      false -> 1
    end
  end

  defp get_possibilities(state) do
    count_ignoring_first_letter(state) + count_counting_first_letter(state)
  end

  defp count_ignoring_first_letter({springs, counts}) do
    if String.match?(springs, ~r/^(\.|\?)/) do
      get_possibilities({String.slice(springs, 1, String.length(springs) - 1), counts})
    else
      0
    end
  end

  defp count_counting_first_letter({springs, [next_count | othercounts]} = cachekey) do
    cache(cachekey, fn ->
      if String.match?(springs, ~r/#|\?/) and String.length(springs) >= next_count and
           not String.match?(binary_slice(springs, 0, next_count), ~r/\./) and
           (String.length(springs) == next_count or String.at(springs, next_count) != "#") do
        get_possibilities({
          String.slice(
            springs,
            min(next_count + 1, String.length(springs)),
            String.length(springs) - min(String.length(springs), next_count + 1)
          ),
          othercounts
        })
      else
        0
      end
    end)
  end

  defp extend_record({springs, counts}) do
    springs =
      2..5
      |> Enum.reduce(springs, fn _, acc ->
        acc <> "?" <> springs
      end)

    counts =
      2..5
      |> Enum.reduce(counts, fn _, acc ->
        acc ++ counts
      end)

    {springs, counts}
  end

  defp parse_record(line) do
    [springs, counts] = String.split(line, " ")

    counts =
      counts
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {springs, counts}
  end

  defp cache(key, fun) do
    with nil <- Process.get(key) do
      tap(fun.(), &Process.put(key, &1))
    end
  end
end
