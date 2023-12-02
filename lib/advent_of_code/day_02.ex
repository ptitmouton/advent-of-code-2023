defmodule AdventOfCode.Day02 do
  @compare %{
    red: 12,
    green: 13,
    blue: 14
  }

  defmodule Reveal do
    defstruct red: 0, green: 0, blue: 0

    def from_description(description_string) do
      Regex.scan(~r/((\d+) (blue|red|green))/U, description_string)
      |> Enum.reduce(%Reveal{}, fn [_, _, count, color], acc ->
        {count, ""} = Integer.parse(count)

        Map.put(acc, String.to_atom(color), count)
      end)
    end

    def merge_greatest_values(%__MODULE__{} = base, %__MODULE{} = other) do
      Map.merge(base, other, fn _keyk, v1, v2 ->
        max(v1, v2)
      end)
    end

    def product(%__MODULE{red: r, green: g, blue: b}), do: r * g * b
  end

  def part1(input) do
    input
    |> get_games()
    |> Enum.filter(fn {_, reveals} ->
      Enum.all?(reveals, fn reveal ->
        reveal.red <= @compare.red &&
          reveal.green <= @compare.green &&
          reveal.blue <= @compare.blue
      end)
    end)
    |> Enum.reduce(0, fn {gameno, _}, acc ->
      acc + gameno
    end)
  end

  def part2(input) do
    input
    |> get_games()
    |> Enum.map(fn {_, reveals} ->
      reveals
      |> Enum.reduce(%Reveal{}, &Reveal.merge_greatest_values(&2, &1))
    end)
    |> Enum.map(&Reveal.product/1)
    |> Enum.reduce(&(&1 + &2))
  end

  defp get_games(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      [description, reveal_list] = String.split(line, ":")

      {game_number, ""} =
        description
        |> String.replace(~r/[^\d+]/, "")
        |> Integer.parse()

      reveals =
        reveal_list
        |> String.split(";")
        |> Enum.map(&Reveal.from_description/1)

      {game_number, reveals}
    end)
  end
end
