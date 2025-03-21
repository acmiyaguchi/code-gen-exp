# MicroKanren Implementation in Lua

This document provides a comprehensive overview of the MicroKanren implementation in Lua. MicroKanren is a minimalist logic programming system inspired by miniKanren, which is itself a simplified version of Kanren.

## Overview

MicroKanren provides core logic programming functionality:
- Logic variables
- Unification
- Goal combinators (conjunction and disjunction)
- Fresh variable introduction
- Stream-based search

This implementation follows the design described in the paper ["µKanren: A Minimal Functional Core for Relational Programming"](http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf) by Jason Hemann and Daniel P. Friedman.

## Data Types

The implementation uses three primary types of terms:

### Variables

Variables represent logical variables that can be bound to values through unification.

```lua
-- Create a variable with auto-incremented ID
local x = mk.var()

-- Create a variable with specific ID
local y = mk.var(42)

-- Check if a term is a variable
mk.is_var(x) -- true
mk.is_var(5) -- false

-- Compare variables for equality (based on ID)
mk.var_eq(x, y) -- false
```

### Values

Values represent concrete data.

```lua
-- Create value terms
local v1 = mk.val(42)    -- Number
local v2 = mk.val("abc") -- String
local v3 = mk.val(true)  -- Boolean
local v4 = mk.val(nil)   -- Nil

-- Check if a term is a value
mk.is_val(v1) -- true
```

### Pairs

Pairs are compound structures that can represent lists and trees.

```lua
-- Create a pair
local p = mk.pair(mk.val(1), mk.val(2))

-- Check if a term is a pair
mk.is_pair(p) -- true

-- Construct a list
local lst = mk.pair(mk.val(1), 
             mk.pair(mk.val(2), 
             mk.pair(mk.val(3), mk.val(nil))))
```

## Substitutions

Substitutions are collections of variable bindings. They are implemented as arrays of pairs (variable, term).

```lua
-- Create an empty substitution
local s = {}

-- Extend a substitution with a new binding
local x = mk.var(1)
local s1 = mk.ext_s(x, mk.val(5), s)

-- Walk a variable through a substitution to find its value
local result = mk.walk(x, s1)
```

### Walking

The `walk` operation follows variable chains to find the ultimate value of a variable.

```lua
local x = mk.var(1)
local y = mk.var(2)
local z = mk.var(3)

-- Create a chain: x -> y -> z -> 42
local s = {
  {x, y},
  {y, z},
  {z, mk.val(42)}
}

-- Follow the complete chain
local result = mk.walk(x, s) -- mk.val(42)
```

## Unification

Unification is a key operation that tries to make two terms equal by finding a substitution that makes them match.

```lua
-- Unify a variable with a value
local x = mk.var(1)
local s1 = mk.unify(x, mk.val(5), {})

-- Unify two variables
local y = mk.var(2)
local s2 = mk.unify(x, y, {})

-- If unification fails, it returns nil
local s3 = mk.unify(mk.val(1), mk.val(2), {}) -- Returns nil
```

Unification can handle complex nested structures:

```lua
-- Unify lists with variables
local list1 = mk.pair(mk.val(1), mk.pair(mk.val(2), mk.pair(mk.var(1), mk.val(nil))))
local list2 = mk.pair(mk.val(1), mk.pair(mk.val(2), mk.pair(mk.val(3), mk.val(nil))))

-- Unification will bind x to 3
local s = mk.unify(list1, list2, {})
```

### Limitations

The current implementation does not perform an occurrence check, meaning it's possible to create cyclic structures through unification. For example:

```lua
local x = mk.var(1)
local p = mk.pair(mk.val(5), x)

-- This should fail with an occurrence check
local s = mk.unify(x, p, {})
```

In a full implementation, this would fail because x occurs in p, and binding x to p would create an infinite structure.

## States and Goals

A state consists of a substitution and a counter for generating fresh variables. A goal is a function that takes a state and returns a stream of states.

### Creating States

```lua
-- Create an initial empty state
local state = mk.empty_state()  -- {{}, 0}
```

### Goal Constructors

#### Equivalence (Unification)

```lua
-- Create a goal that unifies x with 5
local x = mk.var(1)
local goal = mk["=="](x, mk.val(5))

-- Run the goal
local stream = goal(mk.empty_state())
```

#### Conjunction (AND)

```lua
-- Create a goal that requires both x=7 and y=8
local x = mk.var(1)
local y = mk.var(2)
local goal = mk.conj(
  mk["=="](x, mk.val(7)),
  mk["=="](y, mk.val(8))
)
```

#### Disjunction (OR)

```lua
-- Create a goal that allows either x=1 or x=2
local x = mk.var(1)
local goal = mk.disj(
  mk["=="](x, mk.val(1)),
  mk["=="](x, mk.val(2))
)
```

#### Fresh Variables

```lua
-- Create a goal that introduces a fresh variable
local goal = mk.call_fresh(function(x)
  return mk["=="](x, mk.val(5))
end)
```

## Streams

Streams are sequences of states that may be lazy (computations postponed until needed).

```lua
-- Empty stream
local empty = mk.mzero()

-- Stream with a single state
local single = mk.unit(mk.empty_state())

-- Combining streams
local combined = mk.mplus(stream1, stream2)

-- Binding a stream with a goal
local bound = mk.bind(stream, goal)

-- Taking n results from a stream
local results = mk.take(5, stream)
```

## Relational Programming

Using microKanren, you can define relations instead of functions. A relation is a goal constructor that can be run forwards and backwards.

Here's an example of an `appendo` relation (appending two lists):

```lua
local function appendo(l, s, out)
  -- Base case: nil append s = s
  local base = mk.conj(
    mk["=="](l, mk.val(nil)),
    mk["=="](out, s)
  )
  
  -- Recursive case: (x . xs) append s = (x . (xs append s))
  local rec = mk.call_fresh(function(a)
    return mk.call_fresh(function(d)
      return mk.call_fresh(function(res)
        return mk.conj(
          mk["=="](l, mk.pair(a, d)),
          mk.conj(
            mk["=="](out, mk.pair(a, res)),
            appendo(d, s, res)
          )
        )
      end)
    end)
  end)
  
  return mk.disj(base, rec)
end
```

This relation can be used in multiple ways:
- Given two lists, find their concatenation
- Given a concatenation and one list, find the other
- Generate all possible ways to split a list

## Performance Considerations

1. The current implementation uses a simplistic approach to streams and may not handle infinite streams efficiently.
2. Complex goals with deep recursion can lead to performance issues.
3. The lack of occurrence check can lead to infinite loops or memory issues.

## Differences from Reference Implementations

1. This Lua implementation follows the structure of the original µKanren paper but adapts it to Lua's features and limitations.
2. Unlike some implementations, it doesn't include constraint solving or advanced features like Constraint Logic Programming (CLP).
3. It uses direct recursion for relations rather than a trampoline technique for managing call stacks.

## Future Improvements

1. Implement an occurrence check to prevent cyclic structures
2. Add a more efficient implementation of streams using coroutines
3. Implement common relations as built-ins (appendo, membero, etc.)
4. Add constraint solving capabilities
5. Optimize unification and walking for better performance

## References

1. Hemann, J., & Friedman, D. P. (2013). µKanren: A Minimal Functional Core for Relational Programming. Scheme Workshop 2013.
2. Friedman, D. P., Byrd, W. E., & Kiselyov, O. (2005). The Reasoned Schemer. MIT Press.
3. Byrd, W. E. (2009). Relational Programming in miniKanren: Techniques, Applications, and Implementations. Indiana University.