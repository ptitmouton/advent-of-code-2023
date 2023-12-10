defmodule AdventOfCode.Day10 do
  defmodule AdventOfCode.Day10.Cell do
    defstruct x: 0, y: 0, value: ~c"", type: :none

    alias AdventOfCode.Day10.Grid

    def new(x, y, value) do
      %__MODULE__{x: x, y: y, value: value, type: get_type(value)}
    end

    def get_neighbours(%__MODULE__{x: x, y: y}, grid) do
      [{:north, 0, -1}, {:south, 0, 1}, {:east, 1, 0}, {:west, -1, 0}]
      |> Enum.map(fn {direction, xdiff, ydiff} ->
        Grid.at(grid, x + xdiff, y + ydiff)
        |> then(fn neighbor ->
          if neighbor, do: {direction, neighbor}
        end)
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.into(%{})
    end

    def is_same?(%{x: x1, y: y1}, %{x: x2, y: y2}), do: x1 == x2 && y1 == y2
    def is_type?(%{type: t}, type), do: t == type

    def get_next_pipe_path_cells(cell, grid) do
      neighbors = get_neighbours(cell, grid)

      case cell.type do
        :start ->
          neighbors
          |> Enum.filter(fn {_, neighbor} ->
            get_next_pipe_path_cells(neighbor, grid)
            |> Enum.any?(&is_type?(&1, :start))
          end)
          |> Enum.map(&elem(&1, 1))

        :pipe_ns ->
          [neighbors.north, neighbors.south]

        :pipe_ew ->
          [neighbors.east, neighbors.west]

        :pipe_ne ->
          [neighbors.north, neighbors.east]

        :pipe_nw ->
          [neighbors.north, neighbors.west]

        :pipe_sw ->
          [neighbors.south, neighbors.west]

        :pipe_se ->
          [neighbors.south, neighbors.east]

        _ ->
          []
      end
    end

    defp get_type(?S), do: :start
    defp get_type(?|), do: :pipe_ns
    defp get_type(?-), do: :pipe_ew
    defp get_type(?L), do: :pipe_ne
    defp get_type(?J), do: :pipe_nw
    defp get_type(?7), do: :pipe_sw
    defp get_type(?F), do: :pipe_se
    defp get_type(_), do: :none
  end

  defmodule AdventOfCode.Day10.Grid do
    alias AdventOfCode.Day10.Cell

    def parse(input) do
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        line
        |> String.trim()
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          Cell.new(x, y, char)
        end)
      end)
    end

    def map(grid, mapper) do
      Enum.flat_map(grid, fn row ->
        Enum.map(row, &mapper.(&1))
      end)
    end

    def find(grid, finder) do
      Enum.find_value(grid, fn row ->
        Enum.find(row, &finder.(&1))
      end)
    end

    def at([firstrow | _] = grid, x, y)
        when x < 0 or x >= length(firstrow) or y < 0 or y >= length(grid),
        do: nil

    def at(grid, x, y) do
      grid
      |> Enum.at(y)
      |> Enum.at(x)
    end
  end

  alias AdventOfCode.Day10.{Cell, Grid}

  def part1(input) do
    grid = Grid.parse(input)

    start = Grid.find(grid, &(&1.type == :start))

    search_farthest_from_cell(grid, start)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(&max/2)
  end

  def part2(input) do
    grid = Grid.parse(input)

    start = Grid.find(grid, &(&1.type == :start))

    path =
      search_farthest_from_cell(grid, start)
      |> Enum.map(&elem(&1, 0))

    inside_cells =
      Enum.reduce(grid, [], fn line, acc ->
        Enum.reduce(line, %{edges: 0, inside_cells: [], is_on_path: false}, fn cell, s ->
          is_inside = s.edges > 0 && rem(s.edges, 2) == 1

          cond do
            # always count | as an edge
            includes?(path, cell) and Cell.is_type?(cell, :pipe_ns) ->
              Map.put(s, :edges, s.edges + 1)

            includes?(path, cell) and Cell.is_type?(cell, :pipe_ne) ->
              Map.put(s, :edges, s.edges + 1)

            includes?(path, cell) and Cell.is_type?(cell, :pipe_nw) ->
              Map.put(s, :edges, s.edges + 1)

            # If is_on_path was previously set, unset it
            includes?(path, cell) ->
              s

            # The following are the cases where an enclosure happens when edges is odd
            is_inside ->
              s
              |> Map.put(:inside_cells, [cell | s.inside_cells])

            true ->
              s
          end
        end)
        |> Map.get(:inside_cells)
        |> Enum.concat(acc)
      end)

    length(inside_cells)
  end

  defp includes?(list, cell), do: Enum.any?(list, &Cell.is_same?(&1, cell))

  defp search_farthest_from_cell(grid, start) do
    search_farthest_for_paths(
      grid,
      Enum.map(
        Cell.get_next_pipe_path_cells(start, grid),
        &[&1, start]
      )
    )
  end

  defp search_farthest_for_paths(grid, [[leftcell | _] = leftpath, [rightcell | _] = rightpath]) do
    [next_left] =
      Enum.reject(
        Cell.get_next_pipe_path_cells(leftcell, grid),
        &includes?(leftpath, &1)
      )

    [next_right] =
      Enum.reject(
        Cell.get_next_pipe_path_cells(rightcell, grid),
        &includes?(rightpath, &1)
      )

    can_add_next_left =
      Enum.all?(rightpath, &(Cell.is_type?(&1, :start) or !Cell.is_same?(&1, next_left)))

    can_add_next_right =
      Enum.all?(leftpath, &(Cell.is_type?(&1, :start) or !Cell.is_same?(&1, next_right)))

    leftpath =
      if can_add_next_right do
        [next_left | leftpath]
      else
        leftpath
      end

    rightpath =
      if can_add_next_right do
        [next_right | rightpath]
      else
        rightpath
      end

    if can_add_next_left && can_add_next_right do
      search_farthest_for_paths(grid, [leftpath, rightpath])
    else
      Enum.with_index(Enum.reverse(leftpath)) ++
        (Enum.reject(rightpath, fn cell ->
           includes?(leftpath, cell)
         end)
         |> Enum.reverse()
         |> Enum.with_index()
         |> Enum.reverse())
    end
  end
end
