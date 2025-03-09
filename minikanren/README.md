# MicroKanren in Lua

A minimal implementation of the microKanren logic programming system in Lua, designed to solve the 99 Prolog Problems.

## Overview

MicroKanren is a minimalist logic programming system that provides the core functionality of logic programming languages like Prolog. This Lua implementation offers a clean, functional interface for logic programming tasks.

## Features

- Core microKanren implementation in pure Lua
- Logic variables and unification
- Goal combinators (conjunction, disjunction)
- Solution streams with lazy evaluation
- Solutions to the 99 Prolog Problems (in progress)

## Usage

### Basic Usage

```lua
local mk = require("microkanren")

-- Create logic variables
local x = mk.var()

-- Create goals
local goal = mk["=="](x, mk.val(5))

-- Run goals with an empty state
local state = mk.empty_state()
local stream = goal(state)

-- Extract results
local results = mk.take(1, stream)
local result = mk.walk(x, results[1][1])
print(result.value) -- Outputs: 5
```

### Using Built-in Problem Solvers

```lua
local problem1 = require("problems.problem1")

-- Find the last element of a list
local last = problem1.run_last({1, 2, 3, 4, 5})
print(last) -- Outputs: 5
```

## Project Structure

- `microkanren.lua` - Core implementation of the microKanren system
- `problems/` - Solutions to the 99 Prolog Problems 
- `tests/` - Unit tests for both core functionality and problem solutions
- `init.lua` - Initialization file for the library
- `run_tests.lua` - Script to run all tests

## Running Tests

We use the Busted testing framework for running tests. To run the tests, follow these steps:

1. Install Busted if you haven't already:
    ```bash
    luarocks install busted
    ```

2. Run the tests using the provided test runner script:
    ```bash
    busted tests
    ```

## Acknowledgments

- The original microKanren paper by Jason Hemann and Daniel P. Friedman
- The miniKanren community for their ongoing work in logic programming