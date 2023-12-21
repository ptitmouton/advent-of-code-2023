defmodule AdventOfCode.Day19 do
  def part1(input) do
    input
    |> parse_input()
    |> then(fn %{workflows: workflows, part_ratings: part_ratings} ->
      part_ratings
      |> Enum.map(fn prating ->
        send_prating_through_workflow(prating, "in", workflows)
      end)
      |> Enum.filter(&(elem(&1, 1) == :accepted))
      |> Enum.map(fn {prating, :accepted} ->
        prating
        |> Map.values()
        |> Enum.sum()
      end)
      |> Enum.sum()
    end)
  end

  def part2(input) do
    workflows =
      input
      |> parse_input()
      |> Map.get(:workflows)

    %{x: {1, 4000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}}
    |> get_possibilities_for_workflow("in", workflows)
  end

  defp send_prating_through_workflow(prating, "A", _),
    do: {prating, :accepted}

  defp send_prating_through_workflow(prating, "R", _),
    do: {prating, :rejected}

  defp send_prating_through_workflow(prating, workflow_name, workflows),
    do: apply_workflow_steps(prating, Map.get(workflows, workflow_name), workflows)

  defp apply_workflow_steps(prating, [{condition, target} | next_steps], workflows) do
    if prating_meets_condition?(prating, condition) do
      send_prating_through_workflow(prating, target, workflows)
    else
      apply_workflow_steps(prating, next_steps, workflows)
    end
  end

  defp get_possibilities_for_workflow(possibilites, "A", _) do
    possibilites
    |> Map.values()
    |> Enum.map(fn {min, max} ->
      max - min + 1
    end)
    |> Enum.product()
  end

  defp get_possibilities_for_workflow(_, "R", _),
    do: 0

  defp get_possibilities_for_workflow(possibilities, workflow_name, workflows) do
    get_possibilities_for_workflow_steps(
      possibilities,
      Map.get(workflows, workflow_name, []),
      workflows
    )
  end

  defp get_possibilities_for_workflow_steps(
         possibilities,
         [{condition, target} | next_steps],
         workflows
       ) do
    {possibilities, {condition, target}, workflows}

    {meets, nomeet} =
      possibilities_split(possibilities, condition)

    if is_nil(meets) do
      0
    else
      get_possibilities_for_workflow(meets, target, workflows)
    end +
      if is_nil(nomeet) do
        0
      else
        get_possibilities_for_workflow_steps(nomeet, next_steps, workflows)
      end
  end

  defp possibilities_split(possibilities, nil), do: {possibilities, nil}

  defp possibilities_split(possibilities, {var, comparator, value}) do
    case comparator do
      ">" ->
        {
          Map.replace_lazy(possibilities, var, fn {min, max} ->
            {if min < value do
               value + 1
             else
               min
             end, max}
          end),
          Map.replace_lazy(possibilities, var, fn {min, max} ->
            {min,
             if max > value do
               value
             else
               max
             end}
          end)
        }

      "<" ->
        {
          Map.replace_lazy(possibilities, var, fn {min, max} ->
            {min,
             if max > value do
               value - 1
             else
               max
             end}
          end),
          Map.replace_lazy(possibilities, var, fn {min, max} ->
            {if min > value do
               min
             else
               value
             end, max}
          end)
        }
    end
  end

  defp prating_meets_condition?(_, nil), do: true

  defp prating_meets_condition?(prating, {var, comparator, value}) do
    case comparator do
      ">" ->
        prating[var] > value

      "<" ->
        prating[var] < value
    end
  end

  defp parse_input(input) do
    input
    |> String.split("\n\n")
    |> then(fn [workflows, part_ratings] ->
      %{
        workflows:
          workflows
          |> String.split("\n", trim: true)
          |> Enum.map(&parse_workflow/1)
          |> Enum.into(%{}),
        part_ratings:
          part_ratings
          |> String.split("\n", trim: true)
          |> Enum.map(&parse_part_ratings/1)
      }
    end)
  end

  defp parse_workflow(line) do
    Regex.run(~r/([a-z]{2,})\{([a-z]+.*)\}/, line)
    |> then(fn [_, name, steps] ->
      {name, parse_steps(steps)}
    end)
  end

  defp parse_steps(line) do
    line
    |> String.split(",")
    |> Enum.map(fn s ->
      if String.contains?(s, ":") do
        [condition, destination] = String.split(s, ":")

        {parse_condition(condition), destination}
      else
        {nil, s}
      end
    end)
  end

  defp parse_condition(line) do
    [_, part, op, value] =
      Regex.run(~r/([a-z]+)([<>])(\d+)/, line)

    {String.to_atom(part), op, String.to_integer(value)}
  end

  defp parse_part_ratings(line) do
    line
    |> String.trim_leading("\{")
    |> String.trim_trailing("\}")
    |> String.split(",")
    |> Enum.map(fn desc ->
      desc
      |> String.split("=")
      |> then(fn [name, value] ->
        {String.to_atom(name), String.to_integer(value)}
      end)
    end)
    |> Enum.into(%{})
  end
end
