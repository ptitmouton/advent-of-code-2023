# Advent of Code 2023 Elixir

This repository contains my [Advent of Code](https://www.adventofcode.com) 2023 solutions,
implemented in [elixir](https://elixir-lang.org/).

I used mhanberg/advent-of-code-elixir-starter as a starting point,
slightly tweaking it (for example updating elixir and changing the
http client, as in f0e2e1a495f069e66c234d6d329022e78f31f770 )

## Usage

There are 25 modules, 25 tests, and 50 mix tasks.

You will find the implementations in `lib/advent_of_code/`
The tests are located in `test/advent_of_code`

Run `mix test` to run the tests with the public examples from the challenge.
Run `mix dXX.pY` to run the challenge with the personal input:

```bash
# Run all available tests
mix test

# Run the first task of the first day, and the second task of the 14th day
mix d01.p1
mix d14.p2
```

You will need elixir and mix installed to run the examples, as well as having
run `mix deps.get` in the root repository to fetch dependencies.

Make sure you have configured your session cookie to get your personal input,
see below for more information

### Optional Automatic Input Retriever

This starter comes with a module that will automatically get your inputs so you
don't have to mess with copy/pasting. Don't worry, it automatically caches your
inputs to your machine so you don't have to worry about slamming the Advent of
Code server. You will need to configure it with your cookie and make sure to
enable it. You can do this by creating a `config/secrets.exs` file containing
the following:

```elixir
import Config

config :advent_of_code, AdventOfCode.Input,
  allow_network?: true,
  session_cookie: "..." # yours will be longer
```

### Get started coding with zero configuration

#### Using Visual Studio Code

1. [Install Docker Desktop](https://www.docker.com/products/docker-desktop)
1. Open project directory in VS Code
1. Press F1, and select `Remote-Containers: Reopen in Container...`
1. Wait a few minutes as it pulls image down and builds Dev Conatiner Docker image (this should only need to happen once unless you modify the Dockerfile)
   1. You can see progress of the build by clicking `Starting Dev Container (show log): Building image` that appears in bottom right corner
   1. During the build process it will also automatically run `mix deps.get`
1. Once complete VS Code will connect your running Dev Container and will feel like your doing local development
1. If you would like to use a specific version of Elixir change the `VARIANT` version in `.devcontainer/devcontainer.json`
1. If you would like more information about VS Code Dev Containers check out the [dev container documentation](https://code.visualstudio.com/docs/remote/create-dev-container/?WT.mc_id=AZ-MVP-5003399)

#### Compatible with Github Codespaces

1. If you dont have Github Codespaces beta access, sign up for the beta https://github.com/features/codespaces/signup
1. On GitHub, navigate to the main page of the repository.
1. Under the repository name, use the Code drop-down menu, and select Open with Codespaces.
1. If you already have a codespace for the branch, click New codespace.
