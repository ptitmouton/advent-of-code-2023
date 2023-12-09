defmodule AdventOfCode.Day08 do
  def part1(input) do
    {instructions, nodes} =
      parse_input(input)

    get_next_node(
      get_node(nodes, "AAA"),
      instructions,
      nodes,
      &String.equivalent?(&1, "ZZZ"),
      0
    )
  end

  def part2(input) do
    {instructions, nodes} = parse_input(input)

    nodes
    |> Enum.filter(fn {node_name, _} ->
      String.ends_with?(node_name, "A")
    end)
    |> Enum.map(fn node ->
      get_next_node(node, instructions, nodes, &String.ends_with?(&1, "Z"), 0)
    end)
    |> Enum.reduce(&ggv/2)
  end

  defp get_node(nodes, name), do: {name, Map.get(nodes, name)}

  defp kgt(a, b) when rem(a, b) == 0, do: b
  defp kgt(a, b) when a < b, do: kgt(b, a)
  defp kgt(a, b), do: kgt(b, rem(a, b))

  defp ggv(a, b), do: div(a * b, kgt(a, b))

  defp get_next_node({name, {left, right}}, instructions, all_nodes, target_cb, counter) do
    next_direction = get_next_direction(instructions, counter)

    if target_cb.(name) do
      counter
    else
      next_node_name =
        if String.equivalent?(next_direction, "L") do
          left
        else
          right
        end

      next_node = get_node(all_nodes, next_node_name)

      get_next_node(next_node, instructions, all_nodes, target_cb, counter + 1)
    end
  end

  defp get_next_direction(instructions, counter),
    do: Enum.at(instructions, rem(counter, length(instructions)))

  defp parse_input(input) do
    [instructions, nodes] =
      input
      |> String.split("\n\n", trim: true)

    {
      String.graphemes(instructions),
      nodes
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_node/1)
      |> Enum.reduce(%{}, fn {name, directions}, acc ->
        Map.put(acc, name, directions)
      end)
    }
  end

  defp parse_node(line) do
    [[name], [l], [r]] =
      Regex.scan(~r/[A-Z0-9]{3}/, line)

    {name, {l, r}}
  end
end
