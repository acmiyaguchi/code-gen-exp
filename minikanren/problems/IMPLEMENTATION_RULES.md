# Implementation Rules for MicroKanren Problems

> **Note:** This document describes the specific implementation requirements for problem solutions. For a complete overview of the project design and architecture, please refer to the main [DESIGN.md](/DESIGN.md) document in the project root.

## Logic Programming Requirement

All problem solutions in this repository **MUST** be solved using the logic programming capabilities provided by the MicroKanren implementation at the root of this project. This is a strict requirement for all problems.

## Why Logic Programming?

The purpose of this collection is to solve the 99 Prolog problems using the MicroKanren logic programming system. By implementing solutions with MicroKanren, we gain several benefits:

1. Better understanding of logic programming concepts
2. Practice with relational thinking
3. Experience with non-deterministic computation
4. Deeper knowledge of unification and constraint satisfaction

## Implementation Strategy

For each problem, you should:

1. Implement a core solution using MicroKanren's logic programming primitives
2. Test the solution with appropriate test cases

Your solution must use MicroKanren's:
- Logic variables (mk.var)
- Unification (mk["=="])
- Goal combinators (mk.conj, mk.disj)
- Fresh variable creation (mk.call_fresh)

## Direct Implementation vs. Logic Implementation

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

## Reviewing Submissions

When evaluating problem solutions, reviewers should check that:
1. The solution correctly uses logic programming constructs
2. The solution works for all test cases
3. The solution follows the principles of relational programming

Solutions that bypass the logic programming requirement by only providing direct implementations will not be accepted.