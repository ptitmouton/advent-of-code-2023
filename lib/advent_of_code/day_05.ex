defmodule AdventOfCode.Day05 do
  def part1(input) do
    {{_seed_count, seed_stream}, maps} =
      parse_almanach(input)

    seed_stream
    |> Stream.map(fn seed ->
      maps
      |> Enum.reduce(seed, fn {_name, movements}, acc ->
        apply_movements(acc, movements)
      end)
    end)
    |> Enum.min()
  end

  def part2(input) do
    {{_, seed_stream}, maps} =
      parse_almanach(input, seed_range: true)

    seed_stream
    |> Stream.map(fn seed ->
      maps
      |> Enum.reduce(seed, fn {_, movements}, acc ->
        apply_movements(acc, movements)
      end)
    end)
    |> Enum.min()
  end

  defp apply_movements(seed, []), do: seed

  defp apply_movements(seed, [{destination, source, length} | movements]) do
    case move_seed(seed, source, length, destination) do
      ^seed ->
        apply_movements(
          seed,
          movements
        )

      new_seed ->
        new_seed
    end
  end

  defp move_seed(seed, source, length, _destination)
       when seed < source or seed > source + length - 1,
       do: seed

  defp move_seed(seed, source, _length, destination) do
    diff = destination - source
    seed + diff
  end

  defp parse_almanach(input, options \\ [])

  defp parse_almanach(input, options) do
    input
    |> String.split("\n\n")
    |> then(fn [seeds | maps] ->
      {
        parse_seeds(seeds, options),
        Enum.map(maps, &parse_map/1)
      }
    end)
  end

  defp parse_seeds(line, seed_range: true) do
    chunks =
      find_numbers(line)
      |> Enum.chunk_every(2)

    total =
      chunks
      |> Enum.map(fn [_, length] -> length end)
      |> Enum.reduce(&(&1 + &2))

    chunks
    |> Enum.map(fn [start, length] ->
      Range.new(start, start + length - 1)
    end)
    |> Enum.reduce(&Stream.concat/2)
    |> then(&{total, &1})
  end

  defp parse_seeds(line, _options) do
    numbers = find_numbers(line)

    {length(numbers),
     Stream.unfold(numbers, fn
       [] -> nil
       [next | rest] -> {next, rest}
     end)}
  end

  defp parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> then(fn [name | values] ->
      [name, _] = String.split(name, " ")

      {name,
       Enum.map(values, fn line ->
         [destination, source, length] = find_numbers(line)
         {destination, source, length}
       end)}
    end)
  end

  defp find_numbers(line) do
    ~r/\d+/
    |> Regex.scan(line)
    |> Enum.map(fn [number] ->
      String.to_integer(number)
    end)
  end
end
