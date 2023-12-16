defmodule AdventOfCode.Day16 do
  def part1(input) do
    map =
      input
      |> parse_map()

    create_beam()
    |> follow_beam(map)
    |> List.flatten()
    |> Enum.uniq_by(fn {x, y, _} -> {x, y} end)
    |> Enum.count()
  end

  def part2(input) do
    map =
      input
      |> parse_map()

    {width, height} = {length(List.first(map)), length(map)}

    horizontal_beams =
      0..(height - 1)
      |> Enum.map(fn y ->
        [{0, y, :right}, {width - 1, y, :left}]
      end)

    vertical_beams =
      0..(width - 1)
      |> Enum.map(fn x ->
        [{x, 0, :down}, {x, height - 1, :up}]
      end)

    (horizontal_beams ++ vertical_beams)
    |> List.flatten()
    |> Enum.map(&[[&1]])
    |> Task.async_stream(fn beam ->
      beam
      |> follow_beam(map)
      |> List.flatten()
      |> Enum.uniq_by(fn {x, y, _} -> {x, y} end)
      |> Enum.count()
    end)
    |> Enum.max()
    |> elem(1)
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

  defp create_beam(),
    do: [[{0, 0, :right}]]

  defp is_outbounds({x, _, _}, [first_row | _]) when x < 0 or x > length(first_row) - 1,
    do: true

  defp is_outbounds({_, y, _}, rows) when y < 0 or y > length(rows) - 1,
    do: true

  defp is_outbounds(_, _), do: false

  defp follow_beam([[] | beam], _), do: beam

  defp follow_beam([beam_heads | beam], map) do
    # print(map, beam)

    beam_heads =
      beam_heads
      |> Enum.reject(&is_outbounds(&1, map))
      |> Enum.reject(fn next_beam ->
        Enum.any?(List.flatten(beam), fn {bx, by, bd} ->
          bx == elem(next_beam, 0) && by == elem(next_beam, 1) && bd == elem(next_beam, 2)
        end) or is_outbounds(next_beam, map)
      end)

    next_beam_heads =
      beam_heads
      |> Enum.map(fn {x, y, _} = beam ->
        get_next_beam(beam, get_tile(map, x, y))
      end)
      |> List.flatten()
      |> Enum.reject(&is_outbounds(&1, map))

    follow_beam(
      [next_beam_heads | [beam_heads | beam]],
      map
    )
  end

  defp get_next_beam(_, nil), do: nil

  defp get_next_beam({x, y, :right}, ?.), do: {x + 1, y, :right}
  defp get_next_beam({x, y, :left}, ?.), do: {x - 1, y, :left}
  defp get_next_beam({x, y, :up}, ?.), do: {x, y - 1, :up}
  defp get_next_beam({x, y, :down}, ?.), do: {x, y + 1, :down}

  defp get_next_beam({x, y, :left}, ?-), do: {x - 1, y, :left}
  defp get_next_beam({x, y, :right}, ?-), do: {x + 1, y, :right}
  defp get_next_beam({x, y, :up}, ?-), do: [{x - 1, y, :left}, {x + 1, y, :right}]
  defp get_next_beam({x, y, :down}, ?-), do: [{x - 1, y, :left}, {x + 1, y, :right}]
  defp get_next_beam({x, y, :left}, ?|), do: [{x, y - 1, :up}, {x, y + 1, :down}]
  defp get_next_beam({x, y, :right}, ?|), do: [{x, y - 1, :up}, {x, y + 1, :down}]
  defp get_next_beam({x, y, :up}, ?|), do: {x, y - 1, :up}
  defp get_next_beam({x, y, :down}, ?|), do: {x, y + 1, :down}

  defp get_next_beam({x, y, :left}, ?/), do: {x, y + 1, :down}
  defp get_next_beam({x, y, :right}, ?/), do: {x, y - 1, :up}
  defp get_next_beam({x, y, :up}, ?/), do: {x + 1, y, :right}
  defp get_next_beam({x, y, :down}, ?/), do: {x - 1, y, :left}
  defp get_next_beam({x, y, :left}, ?\\), do: {x, y - 1, :up}
  defp get_next_beam({x, y, :right}, ?\\), do: {x, y + 1, :down}
  defp get_next_beam({x, y, :up}, ?\\), do: {x - 1, y, :left}
  defp get_next_beam({x, y, :down}, ?\\), do: {x + 1, y, :right}

  defp get_tile(map, x, y) do
    map
    |> Enum.at(y)
    |> Enum.at(x)
  end
end
