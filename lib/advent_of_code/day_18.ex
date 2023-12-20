defmodule AdventOfCode.Day18 do
  def part1(input) do
    edge_holes =
      input
      |> parse_commands()
      |> dig_holes()

    inner_holes_count =
      edge_holes
      |> get_filling_holes()

    map_size(edge_holes) +
      inner_holes_count
  end

  def part2(input) do
    commands =
      input
      |> parse_color_commands()

    edge_length =
      commands
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    inner_area =
      commands
      |> get_next_point([{0, 0}])
      |> compute_area()

    inner_area + trunc(edge_length / 2) + 1
  end

  defp get_next_point([], points),
    do: Enum.take(points, length(points) - 1)

  defp get_next_point([current_command | next_commands], [{last_x, last_y} | _] = points) do
    next_point =
      case current_command do
        {:right, x} -> {last_x + x, last_y}
        {:left, x} -> {last_x - x, last_y}
        {:up, y} -> {last_x, last_y - y}
        {:down, y} -> {last_x, last_y + y}
      end

    get_next_point(next_commands, [next_point | points])
  end

  defp compute_area(points) do
    0..(length(points) - 1)
    |> Enum.reduce(0, fn i, area ->
      {x1, y1} = Enum.at(points, i)
      # first is always 0, 0
      {x2, y2} = Enum.at(points, i + 1) || {0, 0}

      area + (x1 * y2 - x2 * y1)
    end)
    |> div(2)
    |> abs()
  end

  defp get_grid_dimensions(holes) do
    all_positions =
      holes
      |> Map.keys()

    all_x = Enum.map(all_positions, &elem(&1, 0))
    all_y = Enum.map(all_positions, &elem(&1, 1))

    min_x = Enum.min(all_x)

    min_y = Enum.min(all_y)

    max_x = Enum.max(all_x)

    max_y = Enum.max(all_y)

    {{min_x, max_x}, {min_y, max_y}}
  end

  defp get_filling_holes(holes) do
    {{min_x, max_x}, {min_y, max_y}} = get_grid_dimensions(holes)

    min_y..max_y
    |> Task.async_stream(fn y ->
      Enum.reduce(min_x..max_x, {0, 0}, fn x, {fillings, edge_count} ->
        cond do
          is_horizontal_edge?({x, y}, holes) ->
            {fillings, edge_count + 1}

          not Map.has_key?(holes, {x, y}) and rem(edge_count, 2) == 1 and
              not Map.has_key?(holes, {x, y}) ->
            {fillings + 1, edge_count}

          not Map.has_key?(holes, {x, y}) ->
            {fillings, edge_count}

          true ->
            {fillings, edge_count}
        end
      end)
      |> elem(0)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp is_horizontal_edge?({x, y}, holes) do
    if not is_nil(Map.get(holes, {x, y})) do
      up = Map.get(holes, {x, y - 1})
      right = Map.get(holes, {x + 1, y})
      down = Map.get(holes, {x, y + 1})
      left = Map.get(holes, {x - 1, y})

      case {up, right, down, left} do
        {:is_border, nil, :is_border, nil} ->
          true

        {:is_border, :is_border, nil, nil} ->
          true

        {:is_border, nil, nil, :is_border} ->
          true

        _ ->
          false
      end
    else
      false
    end
  end

  defp dig_holes(commands) do
    dig_next_hole(Map.new(), commands, {0, 0})
  end

  defp dig_next_hole(holes, [], _), do: holes

  defp dig_next_hole(holes, [{_, 0} | next_commands], last_digged_hole),
    do: dig_next_hole(holes, next_commands, last_digged_hole)

  defp dig_next_hole(
         holes,
         [{direction, count} | next_commands],
         last_hole_position
       ) do
    next_coords = get_next_hole_position(last_hole_position, direction)

    holes
    |> Map.put(next_coords, :is_border)
    |> dig_next_hole([{direction, count - 1} | next_commands], next_coords)
  end

  defp get_next_hole_position({curr_x, curr_y}, :right), do: {curr_x + 1, curr_y}
  defp get_next_hole_position({curr_x, curr_y}, :left), do: {curr_x - 1, curr_y}
  defp get_next_hole_position({curr_x, curr_y}, :up), do: {curr_x, curr_y - 1}
  defp get_next_hole_position({curr_x, curr_y}, :down), do: {curr_x, curr_y + 1}

  defp parse_commands(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, dir, count] =
        Regex.run(~r/^([UDLR]) (\d+) \(\#[a-f0-9]{6}\)$/, line)

      dir =
        case dir do
          "L" -> :left
          "R" -> :right
          "U" -> :up
          "D" -> :down
        end

      {dir, String.to_integer(count)}
    end)
  end

  defp parse_color_commands(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, distance, dir] =
        Regex.run(~r/^[UDLR] \d+ \(\#([a-f0-9]{5})([0-3])\)$/, line)

      dir =
        case dir do
          "2" -> :left
          "0" -> :right
          "3" -> :up
          "1" -> :down
        end

      {dir, String.to_integer(distance, 16)}
    end)
  end
end
