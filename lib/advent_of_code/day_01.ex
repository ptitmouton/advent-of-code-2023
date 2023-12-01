defmodule AdventOfCode.Day01 do
  def part1(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(0, fn
      "", acc ->
        acc

      line, acc ->
        calibration =
          line
          |> String.replace(~r/[^\d]/, "")
          |> then(&get_calibration(&1))

        acc + calibration
    end)
  end

  def part2(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      line
      |> find_numbers()
      |> get_calibration()
    end)
    |> Enum.reduce(&(&1 + &2))
  end

  defp get_calibration(numlist) when is_binary(numlist) do
    numlist
    |> String.graphemes()
    |> Enum.map(fn s ->
      Integer.parse(s)
      |> then(fn {int_val, ""} ->
        int_val
      end)
    end)
    |> get_calibration()
  end

  defp get_calibration(numlist) when is_list(numlist) do
    f = List.first(numlist)
    l = List.last(numlist)

    {int_val, ""} = Integer.parse("#{f}#{l}")

    int_val
  end

  defp regex, do: Regex.compile!("(?:\\d|" <> Enum.join(numbers(), "|") <> ")")

  defp find_numbers(str, {numbers, next_offset}) do
    Regex.run(
      regex(),
      str,
      offset: next_offset,
      return: :index
    )
    |> case do
      nil ->
        Enum.reverse(numbers)

      [{index, length}] ->
        value =
          str
          |> String.slice(index, length)
          |> as_number()

        find_numbers(str, {[value | numbers], index + 1})
    end
  end

  defp as_number(num) do
    numbers()
    |> Enum.with_index(1)
    |> Enum.into(%{})
    |> Map.get(num)
    |> case do
      nil ->
        {digit, ""} = Integer.parse(num)
        digit

      digit ->
        digit
    end
  end

  defp find_numbers(str), do: find_numbers(str, {[], 0})

  defp numbers,
    do: [
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine"
    ]
end
