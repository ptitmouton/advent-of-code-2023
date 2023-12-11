defmodule AdventOfCode.Day11 do
  @type universemap() :: list(charlist())
  @type point() :: {x :: integer(), y :: integer()}

  def part1(input) do
    input
    |> parse_map()
    |> expand_universe()
    |> find_galaxies()
    |> make_combinations()
    |> Enum.map(fn {g1, g2} -> calc_distance(g1, g2) end)
    |> Enum.reduce(&(&1 + &2))
  end

  def part2(input, multiplicator \\ 1_000_000) do
    map = parse_map(input)
    galaxies = find_galaxies(map)

    galaxies
    |> update_locations(map, multiplicator)
    |> make_combinations()
    |> Enum.map(fn {g1, g2} -> calc_distance(g1, g2) end)
    |> Enum.reduce(&(&1 + &2))
  end

  @spec calc_distance(point(), point()) :: integer()
  defp calc_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp update_locations(locations, [row | _] = map, multiplicator) do
    expanded_row_indices =
      map
      |> Enum.with_index()
      |> Enum.reject(fn {row, _} ->
        Enum.member?(row, ?#)
      end)
      |> Enum.map(&elem(&1, 1))

    expanded_column_indices =
      0..(length(row) - 1)
      |> Enum.map(fn x ->
        Enum.map(map, &Enum.at(&1, x))
      end)
      |> Enum.with_index()
      |> Enum.reject(fn {column, _} ->
        Enum.member?(column, ?#)
      end)
      |> Enum.map(&elem(&1, 1))

    locations
    |> Enum.map(fn {x, y} ->
      count_rows_to_be_expanded =
        length(Enum.filter(expanded_row_indices, &(&1 < y)))

      count_columns_to_be_expanded =
        length(Enum.filter(expanded_column_indices, &(&1 < x)))

      {x + count_columns_to_be_expanded * multiplicator - count_columns_to_be_expanded,
       y + count_rows_to_be_expanded * multiplicator - count_rows_to_be_expanded}
    end)
  end

  @spec make_combinations(list(any())) :: list({any(), any()})
  defp make_combinations(list) do
    list
    |> Enum.with_index()
    |> Enum.flat_map(fn {entry, i} ->
      Enum.slice(list, (i + 1)..-1)
      |> Enum.map(&{entry, &1})
    end)
  end

  @spec find_galaxies(universe :: map()) :: list(point())
  defp find_galaxies(map) do
    map
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn
        {?#, x} ->
          {x, y}

        _ ->
          nil
      end)
      |> Enum.reject(&is_nil/1)
    end)
  end

  @spec parse_map(binary()) :: universemap()
  defp parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.trim_leading(" ")
      |> String.to_charlist()
    end)
  end

  @spec expand_universe(universemap()) :: universemap()
  defp expand_universe(map) do
    map
    |> expand_empty_rows()
    |> expand_empty_columns()
  end

  @spec expand_empty_rows(universemap()) :: universemap()
  defp expand_empty_rows(map) do
    Enum.flat_map(map, fn row ->
      if Enum.any?(row, &(&1 == ?#)) do
        [row]
      else
        [row, row]
      end
    end)
  end

  @spec expand_empty_columns(universemap()) :: universemap()
  defp expand_empty_columns([row | _] = map) do
    columns =
      0..(length(row) - 1)
      |> Enum.map(fn x ->
        Enum.map(map, &Enum.at(&1, x))
      end)
      |> Enum.map(fn column -> Enum.any?(column, &(&1 == ?#)) end)

    Enum.map(map, fn row ->
      row
      |> Enum.with_index()
      |> Enum.flat_map(fn {char, x} ->
        if Enum.at(columns, x) do
          [char]
        else
          [char, char]
        end
      end)
    end)
  end

  @spec print(universemap()) :: universemap()
  def print(map) do
    tap(map, fn map ->
      map
      |> Enum.map(&to_string/1)
      |> Enum.join("\n")
      |> IO.puts()
    end)
  end
end
