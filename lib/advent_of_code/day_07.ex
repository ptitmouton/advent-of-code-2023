defmodule AdventOfCode.Day07 do
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_game/1)
    |> Enum.map(fn {hand, bid} ->
      {hand, get_hand_label(hand), bid}
    end)
    |> Enum.sort_by(fn {hand, label, _} ->
      [get_label_points(label) | Enum.map(hand, &get_card_points/1)]
      |> List.to_tuple()
    end)
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_, _, bid}, rank}, acc ->
      acc + bid * rank
    end)
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_game/1)
    |> Enum.map(fn {hand, bid} ->
      {hand, get_hand_label_mind_jokers(hand), bid}
    end)
    |> Enum.sort_by(fn {hand, label, _} ->
      [get_label_points(label) | Enum.map(hand, &get_card_points_mind_jokers/1)]
      |> List.to_tuple()
    end)
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_, _, bid}, rank}, acc ->
      acc + bid * rank
    end)
  end

  defp parse_game(line) do
    [hand, bid] =
      line
      |> String.split(" ")

    {
      String.to_charlist(hand),
      String.to_integer(bid)
    }
  end

  defp get_hand_label(hand) do
    hand
    |> Enum.uniq()
    |> Enum.map(fn card ->
      Enum.count(hand, &(&1 == card))
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> case do
      [5] -> :five_of_a_kind
      [4, 1] -> :four_of_a_kind
      [3, 2] -> :full_house
      [3, 1, 1] -> :three_of_a_kind
      [2, 2, 1] -> :two_pairs
      [2, 1, 1, 1] -> :one_pair
      _ -> :high_card
    end
  end

  defp get_hand_label_mind_jokers(hand) do
    most_card_not_J =
      if String.equivalent?(to_string(hand), "JJJJJ") do
        :five_of_a_kind
      else
        hand
        |> Enum.uniq()
        |> Enum.filter(&(&1 != ?J))
        |> Enum.map(fn card ->
          {card, Enum.count(hand, &(&1 == card))}
        end)
        |> Enum.sort_by(fn {_c, count} -> count end, :desc)
        |> List.first()
        |> elem(0)
      end

    get_hand_label(
      Enum.map(hand, fn
        ?J -> most_card_not_J
        c -> c
      end)
    )
  end

  defp get_label_points(:five_of_a_kind), do: 6
  defp get_label_points(:four_of_a_kind), do: 5
  defp get_label_points(:full_house), do: 4
  defp get_label_points(:three_of_a_kind), do: 3
  defp get_label_points(:two_pairs), do: 2
  defp get_label_points(:one_pair), do: 1
  defp get_label_points(:high_card), do: 0
  defp get_card_points(c) when c >= ?2 and c <= ?9, do: c - ?2 + 1
  defp get_card_points(?T), do: 11
  defp get_card_points(?J), do: 12
  defp get_card_points(?Q), do: 13
  defp get_card_points(?K), do: 14
  defp get_card_points(?A), do: 15
  defp get_card_points_mind_jokers(?J), do: 0
  defp get_card_points_mind_jokers(c), do: get_card_points(c)
end
