defmodule AdventOfCode.Day17 do
  defmodule Util do
    @type coordinates :: {x :: integer(), y :: integer()}
    @type value :: pos_integer()
    @type grid :: %{coordinates() => value()}

    @spec get_neighbors(coordinates(), grid()) :: list({coordinates(), value()})
    def get_neighbors({x, y}, map) do
      map
      |> Map.take([{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}])
      |> Map.to_list()
    end
  end

  defmodule PathFinder do
    @type t() :: %PathFinder{
            start_cell: Util.coordinates(),
            visited: %{required(step_key()) => step()},
            frontier: step(),
            completed: MapSet.t(step_key())
          }

    @type direction() :: :right | :left | :up | :down

    @type step_key() ::
            {x :: integer(), y :: integer(), direction(), pos_integer()}

    @type step() ::
            %{
              cell: Util.coordinates(),
              precursor: Util.coordinates() | nil,
              cost: pos_integer(),
              direction: direction(),
              steps: pos_integer()
            }

    defstruct start_cell: nil, visited: Map.new(), completed: MapSet.new(), frontier: [], map: []

    @spec new(
            map :: Util.grid(),
            start_cell :: Util.coordinates(),
            neighbor_step_rejector :: (step(), step() -> boolean())
          ) :: %PathFinder{}
    def new(map, start_cell, neighbor_step_rejector) do
      first_step = %{cell: start_cell, precursor: nil, cost: 0, direction: nil, steps: 0}

      %PathFinder{
        map: map,
        start_cell: start_cell,
        frontier: [first_step],
        visited: %{get_step_key(first_step) => first_step}
      }
      |> create_paths(neighbor_step_rejector)
    end

    defp get_step_key(%{cell: {x, y}, direction: direction, steps: steps}),
      do: {x, y, direction, steps}

    defp create_paths(%PathFinder{frontier: []} = pathfinder, _),
      do: pathfinder

    defp create_paths(
           %PathFinder{frontier: frontier, completed: completed, map: map} = pathfinder,
           neighbor_step_rejector
         ) do
      [cheapest_next | frontier] =
        frontier
        |> Enum.sort_by(& &1.cost)

      next_possible_steps =
        Util.get_neighbors(cheapest_next.cell, map)
        |> Enum.map(fn {neighbor, value} ->
          {direction, steps} = get_next_direction_descriptor(cheapest_next, neighbor)

          %{
            cell: neighbor,
            precursor: cheapest_next.cell,
            cost: cheapest_next.cost + value,
            direction: direction,
            steps: steps
          }
        end)
        |> Enum.reject(fn step ->
          MapSet.member?(completed, get_step_key(step)) or
            step.cell == cheapest_next.precursor or
            neighbor_step_rejector.(cheapest_next, step)
        end)

      next_possible_steps
      |> Enum.reduce(pathfinder, &take_a_visit(&2, &1))
      |> Map.put(
        :completed,
        MapSet.put(completed, get_step_key(cheapest_next))
      )
      |> Map.put(
        :frontier,
        Enum.reject(next_possible_steps, fn ns ->
          Enum.any?(
            frontier,
            &(&1.cell == ns.cell &&
                &1.direction == ns.direction &&
                &1.steps == ns.steps && &1.cost <= ns.cost)
          )
        end) ++
          Enum.reject(frontier, fn f ->
            Enum.any?(
              next_possible_steps,
              &(&1.cell == f.cell &&
                  &1.direction == f.direction &&
                  &1.steps == f.steps &&
                  &1.cost < f.cost)
            )
          end)
      )
      |> create_paths(neighbor_step_rejector)
    end

    @spec take_a_visit(%PathFinder{}, step()) :: %PathFinder{}
    defp take_a_visit(%PathFinder{} = pathfinder, step) do
      pathfinder
      |> Map.put(
        :visited,
        Map.update(pathfinder.visited, get_step_key(step), step, fn
          %{cost: current_cost} when current_cost > step.cost ->
            step

          current_step ->
            current_step
        end)
      )
    end

    defp get_next_direction_descriptor(
           %{cell: {cell_x, cell_y}, direction: direction, steps: steps},
           {target_x, target_y}
         ) do
      case({direction, steps}) do
        {:right, counter} when target_y == cell_y and target_x > cell_x ->
          {:right, counter + 1}

        _ when target_y == cell_y and target_x > cell_x ->
          {:right, 1}

        {:left, counter} when target_y == cell_y and target_x < cell_x ->
          {:left, counter + 1}

        _ when target_y == cell_y and target_x < cell_x ->
          {:left, 1}

        {:up, counter} when target_x == cell_x and target_y < cell_y ->
          {:up, counter + 1}

        _ when target_x == cell_x and target_y < cell_y ->
          {:up, 1}

        {:down, counter} when target_x == cell_x and target_y > cell_y ->
          {:down, counter + 1}

        _ when target_x == cell_x and target_y > cell_y ->
          {:down, 1}
      end
    end

    def get_cheapest_path_value(%PathFinder{visited: visited}, target_cell) do
      visited
      |> Map.values()
      |> Enum.filter(&(&1.cell == target_cell))
      |> Enum.sort_by(& &1.cost)
      |> List.first()
      |> Map.get(:cost)
    end
  end

  def part1(input) do
    {{width, height}, grid} =
      input
      |> parse_grid()

    start = {0, 0}
    target = {width - 1, height - 1}

    grid
    |> PathFinder.new(start, fn _, %{steps: steps} ->
      steps > 3
    end)
    |> PathFinder.get_cheapest_path_value(target)
  end

  def part2(input) do
    {{width, height}, grid} =
      input
      |> parse_grid()

    start = {0, 0}
    target = {width - 1, height - 1}

    grid
    |> PathFinder.new(start, fn %{direction: from_direction, steps: from_steps},
                                %{direction: to_direction, steps: to_steps, cell: {to_x, to_y}} ->
      from_direction != nil and
        (to_steps > 10 or
           (from_steps < 4 and from_direction != to_direction) or
           (to_steps < 4 and
              ((to_direction == :right and to_x == width - 1) or
                 (to_direction == :left and to_x == 0) or
                 (to_direction == :down and to_y == height - 1) or
                 (to_direction == :up and to_y == 0))))
    end)
    |> PathFinder.get_cheapest_path_value(target)
  end

  @spec parse_grid(input :: String.t()) ::
          {{width :: pos_integer(), height :: pos_integer()}, Util.grid()}
  defp parse_grid(input) do
    lines =
      input
      |> String.split("\n", trim: true)

    lines
    |> Enum.with_index()
    |> Enum.reduce(Map.new(), fn {line, y}, grid ->
      line
      |> String.trim_leading()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {value, x}, grid ->
        Map.put(grid, {x, y}, String.to_integer(value))
      end)
    end)
    |> then(fn grid ->
      {{String.length(List.first(lines)), length(lines)}, grid}
    end)
  end
end
