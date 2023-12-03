defmodule AdventOfCode.Day03 do
  defmodule Grid do
    defmodule Cell do
      defstruct x: nil,
                y: nil,
                value: nil,
                is_symbol: false,
                is_digit: false,
                is_empty: true,
                length: 1,
                adjacents: []
    end

    def from_string(input) do
        input
        |> String.split("\n")
        |> Enum.with_index()
        |> Enum.map(fn {line, y} ->
          line
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.map(fn {value, x} ->
            char = List.first(String.to_charlist(value))
            is_digit = char >= List.first(~c"0") && char <= List.first(~c"9")
            is_symbol = !is_digit && value != "."
            is_empty = !is_digit && !is_symbol

            %__MODULE__.Cell{
              x: x,
              y: y,
              value: value,
              is_symbol: is_symbol,
              is_digit: is_digit,
              is_empty: is_empty
            }
          end)
        end)
    end

    def combining_cells(lines) do
          Enum.map(lines, fn line ->
            line
            |> Enum.reduce([], fn cell, acc ->
              last_cell = List.last(acc)

              next_cell_x =
                case last_cell do
                  nil ->
                    0

                  %Cell{x: x, length: length} ->
                    x + length
                end

              if cell.x < next_cell_x do
                acc
              else
                length = calc_cell_length(line, cell)

                value =
                  line
                  |> Enum.slice(cell.x, length)
                  |> Enum.map(& &1.value)
                  |> Enum.join()
                  |> then(fn v ->
                    if cell.is_digit do
                      String.to_integer(v)
                    else
                      v
                    end
                  end)

                acc ++
                  [
                    cell
                    |> Map.put(:value, value)
                    |> Map.put(:length, length)
                  ]
              end
            end)
          end)
    end

    def finding_cell_adjacents(lines) do
        Enum.map(lines, fn line ->
          Enum.map(line, fn cell ->
            Map.put(cell, :adjacents, find_cell_adjacents(lines, cell))
          end)
        end)
    end

    defp find_cell_adjacents(lines, cell) do
      current_line = Enum.at(lines, cell.y)

      last_line =
        if cell.y == 0 do
          nil
        else
          Enum.at(lines, cell.y - 1)
        end

      next_line =
        if cell.y == length(lines) - 1 do
          nil
        else
          Enum.at(lines, cell.y + 1)
        end

      first_cell_index =
        cell.x

      last_cell_index =
        cell.x + cell.length - 1

      before_index =
        if first_cell_index == 0 do
          first_cell_index
        else
          cell.x - 1
        end

      next_index =
        if last_cell_index == length(current_line) - 1 do
          last_cell_index
        else
          last_cell_index + 1
        end

      [last_line, current_line, next_line]
      |> Enum.filter(&(!is_nil(&1)))
      |> Enum.reduce([], fn line, acc ->
        current_line_adjacents =
          Enum.filter(line, fn c ->
            c.x + c.length - 1 >= before_index && c.x <= next_index && !is_same_cell(cell, c)
          end)

        if cell.x == 0 && cell.y == 0 do
          acc ++ current_line_adjacents
        else
          acc ++ current_line_adjacents
        end
      end)
    end

    defp is_same_cell(cell1, cell2), do: cell1.x == cell2.x && cell1.y == cell2.y

    defp calc_cell_length(_, %Cell{is_digit: false}), do: 1

    defp calc_cell_length(line, %Cell{x: x, length: length}) when x + length >= length(line),
      do: length

    defp calc_cell_length(line, %Cell{x: x, length: length}) do
      case Enum.find(line, &(&1.x == x + 1)) do
        %{is_digit: true} = next_cell ->
          length + calc_cell_length(line, next_cell)

        %{is_digit: false} ->
          length
      end
    end
  end

  def part1(input) do
    input
    |> Grid.from_string()
    |> Grid.combining_cells()
    |> Grid.finding_cell_adjacents()
    |> Enum.flat_map(fn line ->
      line
      |> Enum.filter(fn cell ->
        cell.is_digit && Enum.any?(cell.adjacents, & &1.is_symbol)
      end)
    end)
    |> Enum.reduce(0, &(&1.value + &2))
  end

  def part2(input) do
    input
    |> Grid.from_string()
    |> Grid.combining_cells()
    |> Grid.finding_cell_adjacents()
    |> Enum.flat_map(fn line ->
      line
      |> Enum.filter(&(&1.value == "*"))
      |> Enum.map(fn cell ->
        cell
        |> Map.get(:adjacents)
        |> Enum.filter(&(&1.is_digit))
        |> Enum.map(&(&1.value))
        |> case do
          digits when length(digits) >= 2 ->
            Enum.product(digits)
          _ ->
            nil
        end
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(&(&1 + &2))
  end
end
