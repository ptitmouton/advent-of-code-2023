defmodule AdventOfCode.Day06 do
  def part1(input) do
    input
    |> parse_races()
    |> Enum.map(fn {time, distance} ->
      get_possible_distances(time)
      |> Enum.filter(&(&1 > distance))
      |> length()
    end)
    |> Enum.product()
  end

  def part2(input) do
    {time, distance} =
      input
      |> parse_races()
      |> Enum.reduce({"", ""}, fn {t, d}, {time, distance} ->
        {time <> Integer.to_string(t), distance <> Integer.to_string(d)}
      end)

    time = String.to_integer(time)
    distance = String.to_integer(distance)

    get_max_press_time(time, distance) - get_min_press_time(time, distance) + 1
  end

  defp get_min_press_time(total_time, max_distance),
    do: get_min_press_time(1, total_time, max_distance, trunc(total_time / 100))

  defp get_min_press_time(press_time, total_time, max_distance, step) do
    distance =
      get_distance_for_button_press(press_time, total_time)

    if distance > max_distance do
      if step == 1 do
        press_time
      else
        get_min_press_time(
          press_time - step - 1,
          total_time,
          max_distance,
          trunc(step / 10) + 1
        )
      end
    else
      get_min_press_time(press_time + step, total_time, max_distance, step)
    end
  end

  defp get_max_press_time(total_time, max_distance),
    do: get_max_press_time(total_time - 1, total_time, max_distance, trunc(total_time / 100))

  defp get_max_press_time(press_time, total_time, max_distance, step) do
    distance =
      get_distance_for_button_press(press_time, total_time)

    if distance > max_distance do
      if step == 1 do
        press_time
      else
        get_max_press_time(
          press_time + step + 1,
          total_time,
          max_distance,
          trunc(step / 10) + 1
        )
      end
    else
      get_max_press_time(press_time - step, total_time, max_distance, step)
    end
  end

  defp get_possible_distances(total_time) do
    Range.new(1, total_time - 1)
    |> Enum.map(fn press_time ->
      get_distance_for_button_press(press_time, total_time)
    end)
  end

  defp get_distance_for_button_press(press_time, total_time) do
    unpress_time = total_time - press_time

    speed =
      Range.new(1, press_time)
      |> Enum.reduce(0, fn _timer, speed ->
        speed + 1
      end)

    unpress_time * speed
  end

  defp parse_races(input) do
    [times, distances] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&find_numbers/1)

    Enum.zip(times, distances)
  end

  defp find_numbers(line) do
    ~r/\d+/
    |> Regex.scan(line)
    |> Enum.map(fn [number] ->
      String.to_integer(number)
    end)
  end
end
