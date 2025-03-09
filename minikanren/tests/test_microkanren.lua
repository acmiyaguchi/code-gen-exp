local mk = require("microkanren")

local function test_unification()
  -- Create variables
  local x = mk.var(1)
  local y = mk.var(2)
  
  -- Test simple unification
  local s1 = mk.unify(x, mk.val(5), {})
  assert(#s1 == 1, "Substitution should have one binding")
  
  local result = mk.walk(x, s1)
  assert(result.type == "val" and result.value == 5, "Walking x should yield 5")
  
  -- Test unification of two variables
  local s2 = mk.unify(x, y, {})
  assert(#s2 == 1, "Substitution should have one binding")
  
  -- Test transitivity
  local s3 = mk.unify(y, mk.val(10), s2)
  assert(#s3 == 2, "Substitution should have two bindings")
  
  result = mk.walk(x, s3)
  assert(result.type == "val" and result.value == 10, "Walking x should yield 10 through y")
  
  -- Test failure
  local s4 = mk.unify(mk.val(1), mk.val(2), {})
  assert(s4 == nil, "Unifying different constants should fail")
  
  print("Unification tests passed!")
end

local function test_goals()
  -- Create variables
  local x = mk.var(1)
  
  -- Test equivalent goal
  local g1 = mk["=="](x, mk.val(5))
  local state = mk.empty_state()
  local stream = g1(state)
  
  assert(#stream > 0, "Stream should not be empty")
  
  local results = mk.take(1, stream)
  assert(#results == 1, "Should get one result")
  
  local result_x = mk.walk(x, results[1][1])
  assert(result_x.type == "val" and result_x.value == 5, "x should be bound to 5")
  
  -- Test conjunction
  local y = mk.var(2)
  local g2 = mk.conj(
    mk["=="](x, mk.val(7)),
    mk["=="](y, mk.val(8))
  )
  
  stream = g2(mk.empty_state())
  results = mk.take(1, stream)
  assert(#results == 1, "Should get one result for conjunction")
  
  result_x = mk.walk(x, results[1][1])
  local result_y = mk.walk(y, results[1][1])
  assert(result_x.type == "val" and result_x.value == 7, "x should be bound to 7")
  assert(result_y.type == "val" and result_y.value == 8, "y should be bound to 8")
  
  -- Test disjunction
  local g3 = mk.disj(
    mk["=="](x, mk.val(1)),
    mk["=="](x, mk.val(2))
  )
  
  stream = g3(mk.empty_state())
  results = mk.take(2, stream)
  assert(#results == 2, "Should get two results for disjunction")
  
  print("Goal tests passed!")
end

local function test_fresh()
  -- Test call_fresh
  local g = mk.call_fresh(function(x)
    return mk["=="](x, mk.val(5))
  end)
  
  local stream = g(mk.empty_state())
  local results = mk.take(1, stream)
  assert(#results == 1, "Should get one result")
  
  -- Get the variable from the state
  local x = mk.var(0)  -- The fresh variable will have ID 0
  local result_x = mk.walk(x, results[1][1])
  assert(result_x.type == "val" and result_x.value == 5, "Fresh variable should be bound to 5")
  
  print("Fresh variable test passed!")
end

-- Run tests
test_unification()
test_goals()
test_fresh()

print("All tests passed!")
