defmodule AdventOfCode.Day15 do
  def part1(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part2(input) do
    boxes =
      0..255
      |> Enum.map(&{&1, []})
      |> Enum.into(%{})

    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse_lens/1)
    |> Enum.reduce(boxes, &apply_lens(&1, &2))
    |> Enum.map(fn {box, lenses} ->
      lenses
      |> Enum.with_index(1)
      |> Enum.map(fn {{_, focal}, slot} ->
        (box + 1) * slot * focal
      end)
    end)
    |> List.flatten()
    |> Enum.sum()
  end

  defp apply_lens({:del, label, box}, boxes) do
    Map.replace_lazy(boxes, box, fn content ->
      Enum.reject(
        content,
        &(elem(&1, 0) == label)
      )
    end)
  end

  defp apply_lens({:add, label, box, focal}, boxes) do
    Map.replace_lazy(boxes, box, fn content ->
      if Enum.any?(content, fn {l, _} -> l == label end) do
        Enum.map(content, fn
          {^label, _} -> {label, focal}
          lens -> lens
        end)
      else
        content ++ [{label, focal}]
      end
    end)
  end

  defp parse_lens(input) do
    Regex.run(~r/^(.+)(=|-)(\d+)?$/, input)
    |> then(fn
      [_, label, "=", focal] ->
        {:add, label, hash(label), String.to_integer(focal)}

      [_, label, "-"] ->
        {:del, label, hash(label)}
    end)
  end

  defp hash(input) do
    hash(to_charlist(input), 0)
  end

  defp hash([], value), do: value

  defp hash([char | next_chars], current) do
    hash(next_chars, rem((current + char) * 17, 256))
  end
end
