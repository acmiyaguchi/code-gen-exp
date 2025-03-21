# MicroKanren in Lua: Solving the 99 Prolog Problems

## 1. Introduction

This document outlines the design and implementation of a microKanren logic programming system in Lua. The primary goal is to solve the 99 Prolog problems using this custom microKanren implementation, while ensuring robust unit testing.

## 2. Goals

* Implement a minimal but functional microKanren core in Lua.
* Solve the 99 Prolog problems using the implemented microKanren.
* Develop a comprehensive suite of unit tests for both the core and problem solutions.
* Maintain a clean, well-organized, and maintainable codebase.

## 3. Architecture

The project is structured into the following components:

* **`microkanren.lua` (Core Implementation):** Contains the core logic of the microKanren system, including data structures (terms, substitutions, streams) and functions (unification, goal combinators).
* **`problems/` (Problem Solutions):** Houses the Lua modules that implement solutions to the 99 Prolog problems using the microKanren core.
* **`tests/` (Unit Tests):** Contains the unit tests for both the core implementation and the problem solutions, using the Busted testing framework.

### 3.1. MicroKanren Core

* **Data Structures:**
    * **Terms:** Represented as Lua tables with `type` fields (`var`, `val`, `pair`).
    * **Substitutions:** Lua tables (dictionaries) mapping variable IDs to terms.
    * **Streams:** Lazy sequences of substitutions implemented using Lua coroutines.
* **Functions:**
    * `var(x)`: Creates a logic variable.
    * `val(x)`: Creates a value term.
    * `pair(a, b)`: Creates a pair term.
    * `unify(u, v, s)`: Unifies terms `u` and `v` under substitution `s`.
    * `walk(u, s)`: Follows variable chains in substitution `s`.
    * `ext_s(x, v, s)`: Extends substitution `s` with a new binding.
    * `mzero()`: Creates an empty stream.
    * `unit(s)`: Creates a stream with a single substitution.
    * `bind(stream, goal)`: Applies a goal to each substitution in a stream.
    * `disj(g1, g2)`: Creates a disjunctive goal (OR).
    * `conj(g1, g2)`: Creates a conjunctive goal (AND).
    * `call_fresh(f)`: Creates a fresh logic variable.
    * `take(n, stream)`: Takes the first `n` substitutions from a stream.

### 3.2. Problem Solutions

* Each Prolog problem is implemented as a separate Lua module within the `problems/` directory.
* Problem solutions are defined as microKanren goals, utilizing the core functions.
* Data structures (lists, etc.) are represented using Lua tables.

## 4. Implementation Requirements

### 4.1. Logic Programming Requirement

**All problem solutions in this repository MUST be solved using the logic programming capabilities provided by the MicroKanren implementation.** This is a strict requirement for all problems.

### 4.2. Why Logic Programming?

The purpose of this collection is to solve the 99 Prolog problems using the MicroKanren logic programming system. By implementing solutions with MicroKanren, we gain several benefits:

1. Better understanding of logic programming concepts
2. Practice with relational thinking
3. Experience with non-deterministic computation
4. Deeper knowledge of unification and constraint satisfaction

### 4.3. Implementation Strategy

For each problem, you should:

1. Implement a core solution using MicroKanren's logic programming primitives
2. Test the solution with appropriate test cases

Your solution must use MicroKanren's:
- Logic variables (mk.var)
- Unification (mk["=="])
- Goal combinators (mk.conj, mk.disj)
- Fresh variable creation (mk.call_fresh)

### 4.4. Direct Implementation vs. Logic Implementation

It is acceptable and often useful to have a direct, non-logic-based implementation alongside your logic implementation for:

- Generating test cases
- Validating results
- Performance comparisons

However, the direct implementation should be clearly marked as a helper function and **CANNOT** be considered the actual solution to the problem. The real solution must use logic programming.

Example structure:
```lua
-- Direct implementation (for testing/validation only)
function M.direct_last(arr)
  return arr[#arr]
end

-- Logic-based implementation (the actual solution)
function M.last_element(lst, last)
  -- Your logic programming solution using microkanren primitives
end

-- Runner function that uses logic programming
function M.run_last(arr)
  -- Convert input to logic form
  local lst = make_list(arr)
  local last_var = mk.var(0)
  
  -- Run the logic solution
  local state = mk.empty_state()
  local stream = M.last_element(lst, last_var)(state)
  local results = mk.take(1, stream)
  
  -- Return result
  if #results > 0 then
    local result = mk.walk(last_var, results[1][1])
    if result.type == "val" then
      return result.value
    end
  end
  return nil
end
```

## 5. Data Representation

* **Lists:** Represented as Lua tables (e.g., `{1, 2, 3}`).
* **Variables:** Represented as `{type = "var", id = <unique_id>}`.
* **Values:** Represented as `{type = "val", value = <value>}`.
* **Pairs:** Represented as `{type = "pair", left = <term>, right = <term>}`.

## 6. Stream Implementation

* Lua coroutines are used to implement lazy streams, enabling efficient generation of solutions.

## 7. Unification

* The `unify` function implements the core unification algorithm, handling variable binding and term comparison.

## 8. Goal Combinators

* `conj` and `disj` provide the ability to combine goals using logical AND and OR operators.
* `call_fresh` introduces new logic variables into the goal evaluation.

## 9. Testing Strategy

* **MicroKanren Core Tests:** Verify the correctness of the core functions, including unification, stream operations, and goal combinators.
* **Problem Solution Tests:** Ensure that each problem solution produces the expected results for various inputs.
* **Test Coverage:** Aim for comprehensive test coverage, including edge cases and boundary conditions.
* **Continuous Integration:** Integrate automated testing into a CI pipeline (e.g., GitHub Actions) to ensure code quality.

## 10. Project Structure

```
microkanren-lua/
├── microkanren.lua
├── init.lua
├── microkanren_spec.lua
├── problems/
│   ├── README.md
│   ├── IMPLEMENTATION_RULES.md
│   ├── p01/
│   │   ├── main.lua
│   │   └── main_spec.lua
│   ├── p02/
│   │   ├── main.lua
│   │   └── main_spec.lua
│   └── ...
```

## 11. Development Process

1.  **Implement the microKanren core.**
2.  **Write unit tests for the core.**
3.  **Implement solutions for the 99 Prolog problems.**
4.  **Write unit tests for each problem solution.**
5.  **Refactor and improve code quality.**
6.  **Integrate with a CI/CD pipeline.**
7.  **Document the code and project.**

## 12. Future Enhancements

* **Performance Optimization:** Profile and optimize the microKanren implementation for performance.
* **Constraint Logic Programming:** Extend the microKanren implementation to support constraint logic programming.
* **More Advanced Features:** Implement features like negation as failure and cut.
* **Documentation:** Create thorough documentation for the project.
* **Examples:** Create more usage examples for the microkanren library.

## 13. Conclusion

This design document provides a roadmap for implementing a microKanren system in Lua and solving the 99 Prolog problems. By adhering to this design and the implementation requirements, we aim to create a robust, maintainable, and well-tested logic programming system that properly leverages the power of relational programming.