local mk = require("microkanren")

describe("Streams and Goal Constructors", function()
  it("should create an empty stream", function()
    local stream = mk.mzero()
    assert.are.equal(0, #stream)
  end)
  
  it("should create a stream with a single state", function()
    local state = mk.empty_state()
    local stream = mk.unit(state)
    
    assert.are.not_equal(0, #stream)
    assert.are.same(state, stream[1])
  end)
  
  it("should create an initial empty state", function()
    local state = mk.empty_state()
    
    assert.is_table(state)
    assert.are.equal(2, #state)
    assert.is_table(state[1])  -- Substitution
    assert.are.equal(0, state[2])  -- Counter
  end)
  
  it("should create and run a goal", function()
    local x = mk.var(1)
    local goal = mk["=="](x, mk.val(5))
    
    assert.is_function(goal)
    
    local state = mk.empty_state()
    local stream = goal(state)
    
    assert.is_not_nil(stream)
    assert.is_table(stream)
  end)
  
  describe("Goal operators", function()
    it("should create a conjunction goal", function()
      local x = mk.var(1)
      local y = mk.var(2)
      local g = mk.conj(
        mk["=="](x, mk.val(7)),
        mk["=="](y, mk.val(8))
      )
      
      local stream = g(mk.empty_state())
      local results = mk.take(1, stream)
      assert.are.equal(1, #results)
      
      local result_x = mk.walk(x, results[1][1])
      local result_y = mk.walk(y, results[1][1])
      assert.are.equal(7, result_x.value)
      assert.are.equal(8, result_y.value)
    end)
    
    it("should create a disjunction goal", function()
      local x = mk.var(1)
      local g = mk.disj(
        mk["=="](x, mk.val(1)),
        mk["=="](x, mk.val(2))
      )
      
      local stream = g(mk.empty_state())
      local results = mk.take(2, stream)
      
      assert.are.equal(2, #results)
      
      -- Check that we got both values (order may vary)
      local values = {
        mk.walk(x, results[1][1]).value,
        mk.walk(x, results[2][1]).value
      }
      table.sort(values)
      assert.are.same({1, 2}, values)
    end)
    
    it("should handle complex goal combinations", function()
      local x = mk.var(1)
      local y = mk.var(2)
      
      -- (x == 1 || x == 2) && (y == 3 || y == 4)
      local g = mk.conj(
        mk.disj(
          mk["=="](x, mk.val(1)),
          mk["=="](x, mk.val(2))
        ),
        mk.disj(
          mk["=="](y, mk.val(3)),
          mk["=="](y, mk.val(4))
        )
      )
      
      local stream = g(mk.empty_state())
      local results = mk.take(4, stream)
      
      assert.are.equal(4, #results)
      
      -- We should have all combinations: (1,3), (1,4), (2,3), (2,4)
      local pairs = {}
      for i, result in ipairs(results) do
        local x_val = mk.walk(x, result[1]).value
        local y_val = mk.walk(y, result[1]).value
        table.insert(pairs, {x_val, y_val})
      end
      
      -- Sort for consistent comparison
      table.sort(pairs, function(a, b)
        if a[1] == b[1] then
          return a[2] < b[2]
        end
        return a[1] < b[1]
      end)
      
      assert.are.same({{1, 3}, {1, 4}, {2, 3}, {2, 4}}, pairs)
    end)
  end)
  
  describe("Fresh Variables", function()
    it("should create a fresh variable", function()
      local g = mk.call_fresh(function(x)
        return mk["=="](x, mk.val(5))
      end)
      
      local stream = g(mk.empty_state())
      local results = mk.take(1, stream)
      assert.are.equal(1, #results)
      
      local x = mk.var(0)
      local result_x = mk.walk(x, results[1][1])
      assert.are.equal(5, result_x.value)
    end)
    
    it("should increment the counter for each fresh variable", function()
      local g = mk.call_fresh(function(x)
        return mk.call_fresh(function(y)
          return mk.conj(
            mk["=="](x, mk.val(5)),
            mk["=="](y, mk.val(10))
          )
        end)
      end)
      
      local stream = g(mk.empty_state())
      local results = mk.take(1, stream)
      
      -- Check that the final counter is 2 (after creating 2 fresh vars)
      assert.are.equal(2, results[1][2])
      
      -- Check both variables got bound correctly
      local x = mk.var(0)
      local y = mk.var(1)
      assert.are.equal(5, mk.walk(x, results[1][1]).value)
      assert.are.equal(10, mk.walk(y, results[1][1]).value)
    end)
  end)
  
  describe("Stream operations", function()
    it("should append streams", function()
      local s1 = mk.unit(mk.empty_state())
      local s2 = mk.unit({{{mk.var(0), mk.val(42)}}, 1})
      
      local s3 = mk.mplus(s1, s2)
      local results = mk.take(2, s3)
      
      assert.are.equal(2, #results)
    end)
    
    it("should bind a stream with a goal", function()
      local s1 = mk.unit(mk.empty_state())
      local goal = mk.call_fresh(function(x)
        return mk["=="](x, mk.val(5))
      end)
      
      local s2 = mk.bind(s1, goal)
      local results = mk.take(1, s2)
      
      assert.are.equal(1, #results)
      local x = mk.var(0)
      assert.are.equal(5, mk.walk(x, results[1][1]).value)
    end)
    
    it("should take N results from a stream", function()
      local x = mk.var(0)
      local g = mk.disj(
        mk["=="](x, mk.val(1)),
        mk.disj(
          mk["=="](x, mk.val(2)),
          mk["=="](x, mk.val(3))
        )
      )
      
      local stream = g(mk.empty_state())
      
      local results1 = mk.take(1, stream)
      assert.are.equal(1, #results1)
      
      local results2 = mk.take(2, stream)
      assert.are.equal(2, #results2)
      
      local results3 = mk.take(3, stream)
      assert.are.equal(3, #results3)
      
      -- Taking more than available should return what's available
      local results4 = mk.take(10, stream)
      assert.are.equal(3, #results4)
    end)
  end)
end)