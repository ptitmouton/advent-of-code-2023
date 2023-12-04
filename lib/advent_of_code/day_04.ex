defmodule AdventOfCode.Day04 do
  def part1(input) do
    input
    |> get_games()
    |> Enum.map(&(length(get_winning_numbers(&1))))
    |> Enum.reduce(0, fn win_counts, acc ->
      case win_counts do
        0 ->
          acc

        win_counts ->
          trunc(:math.pow(2, win_counts - 1)) + acc
      end
    end)
  end

  def part2(input) do
    input
    |> get_games()
    |> Enum.map(&{1, &1})
    |> win_more_scratchcards()
    |> Enum.reduce(0, fn {count, _}, acc -> acc + count end)
  end

  defp get_winning_numbers({_, winning, having}) do
      having
      |> Enum.filter(fn h ->
        Enum.any?(winning, &(&1 == h))
      end)
  end

  defp win_more_scratchcards(scratchcards), do: win_more_scratchcards(scratchcards, 0)

  defp win_more_scratchcards(scratchbag, current_index) do
    {current_count, current_scratchcard} = Enum.at(scratchbag, current_index)
    win_counts =
      current_scratchcard
      |> get_winning_numbers()
      |> length()

    winning_scratchcards =
      Enum.slice(scratchbag, current_index + 1, win_counts)
      |> Enum.map(fn {count, scratchcard} ->
        {count + current_count, scratchcard}
      end)

    new_scratchbag =
      (Enum.slice(scratchbag, 0, current_index + 1) ++
         winning_scratchcards ++
         Enum.slice(
           scratchbag,
           current_index + 1 + length(winning_scratchcards),
           length(scratchbag) - current_index + length(winning_scratchcards)
         ))

    if current_index == length(scratchbag) - 1 do
      new_scratchbag
    else
      win_more_scratchcards(new_scratchbag, current_index + 1)
    end
  end

  defp get_games(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      [description, numbers] = String.split(line, ":")

      game_number =
        description
        |> String.replace(~r/[^\d+]/, "")
        |> String.to_integer()

      [winning, having] =
        numbers
        |> String.split("|")
        |> Enum.map(fn numberlist ->
          numberlist
          |> String.split(" ")
          |> Enum.filter(&(&1 != ""))
          |> Enum.map(&String.to_integer/1)
        end)

      {game_number, winning, having}
    end)
  end
end
