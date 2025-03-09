local mk = require("microkanren")
local busted = require("busted")

describe("MicroKanren", function()
  describe("Unification", function()
    it("should unify a variable with a value", function()
      local x = mk.var(1)
      local s1 = mk.unify(x, mk.val(5), {})
      assert.is_not_nil(s1)
      assert.are.equal(1, #s1)
      
      local result = mk.walk(x, s1)
      assert.are.equal("val", result.type)
      assert.are.equal(5, result.value)
    end)
    
    it("should unify two variables", function()
      local x = mk.var(1)
      local y = mk.var(2)
      local s2 = mk.unify(x, y, {})
      assert.is_not_nil(s2)
      assert.are.equal(1, #s2)
      
      local s3 = mk.unify(y, mk.val(10), s2)
      assert.is_not_nil(s3)
      assert.are.equal(2, #s3)
      
      local result = mk.walk(x, s3)
      assert.are.equal("val", result.type)
      assert.are.equal(10, result.value)
    end)
    
    it("should fail to unify different constants", function()
      local s4 = mk.unify(mk.val(1), mk.val(2), {})
      assert.is_nil(s4)
    end)
  end)
  
  describe("Goals", function()
    it("should create an equivalent goal", function()
      local x = mk.var(1)
      local g1 = mk["=="](x, mk.val(5))
      local state = mk.empty_state()
      local stream = g1(state)
      
      assert.is_not_nil(stream)
      assert.is_true(#stream > 0)
      
      local results = mk.take(1, stream)
      assert.are.equal(1, #results)
      
      local result_x = mk.walk(x, results[1][1])
      assert.are.equal("val", result_x.type)
      assert.are.equal(5, result_x.value)
    end)
    
    it("should create a conjunction goal", function()
      local x = mk.var(1)
      local y = mk.var(2)
      local g2 = mk.conj(
        mk["=="](x, mk.val(7)),
        mk["=="](y, mk.val(8))
      )
      
      local stream = g2(mk.empty_state())
      local results = mk.take(1, stream)
      assert.are.equal(1, #results)
      
      local result_x = mk.walk(x, results[1][1])
      local result_y = mk.walk(y, results[1][1])
      assert.are.equal("val", result_x.type)
      assert.are.equal(7, result_x.value)
      assert.are.equal("val", result_y.type)
      assert.are.equal(8, result_y.value)
    end)
    
    it("should create a disjunction goal", function()
      local x = mk.var(1)
      local g3 = mk.disj(
        mk["=="](x, mk.val(1)),
        mk["=="](x, mk.val(2))
      )
      
      local stream = g3(mk.empty_state())
      local results = mk.take(2, stream)
      assert.are.equal(2, #results)
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
      assert.are.equal("val", result_x.type)
      assert.are.equal(5, result_x.value)
    end)
  end)
end)
