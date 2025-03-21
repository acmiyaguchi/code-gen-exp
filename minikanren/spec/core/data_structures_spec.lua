local mk = require("microkanren")
local helpers = require("spec.core.helpers")
local make_list = helpers.make_list

describe("Data Structures", function()

  describe("Variables", function()
    it("should create variables with appropriate IDs", function()
      -- Note: In the current implementation, mk.var() without args uses
      -- a shared counter, so we specify explicit IDs for testing
      local x = mk.var(100)
      local y = mk.var(101)
      local z = mk.var(42)  -- Explicit ID
      
      assert.are.equal("var", x.type)
      assert.are.equal("var", y.type)
      assert.are.not_equal(x.id, y.id)
      assert.are.equal(42, z.id)
    end)
    
    it("should identify variables correctly", function()
      local x = mk.var()
      local v = mk.val(5)
      local p = mk.pair(mk.val(1), mk.val(2))
      
      assert.is_true(mk.is_var(x))
      assert.is_false(mk.is_var(v))
      assert.is_false(mk.is_var(p))
      assert.is_false(mk.is_var(nil))
      assert.is_false(mk.is_var(42))
    end)
    
    it("should compare variables for equality", function()
      local x = mk.var(1)
      local y = mk.var(1)  -- Same ID
      local z = mk.var(2)  -- Different ID
      
      assert.is_true(mk.var_eq(x, y))
      assert.is_false(mk.var_eq(x, z))
      assert.is_false(mk.var_eq(x, mk.val(1)))
    end)
  end)
  
  describe("Values", function()
    it("should create value terms with different data types", function()
      local v1 = mk.val(42)
      local v2 = mk.val("hello")
      local v3 = mk.val(true)
      local v4 = mk.val(nil)
      
      assert.are.equal("val", v1.type)
      assert.are.equal(42, v1.value)
      assert.are.equal("hello", v2.value)
      assert.are.equal(true, v3.value)
      assert.is_nil(v4.value)
    end)
    
    it("should identify values correctly", function()
      local v = mk.val(5)
      local x = mk.var()
      
      assert.is_true(mk.is_val(v))
      assert.is_false(mk.is_val(x))
      assert.is_false(mk.is_val(nil))
    end)
  end)
  
  describe("Pairs", function()
    it("should create pair terms", function()
      local p = mk.pair(mk.val(1), mk.val(2))
      
      assert.are.equal("pair", p.type)
      assert.are.equal(1, p.left.value)
      assert.are.equal(2, p.right.value)
    end)
    
    it("should identify pairs correctly", function()
      local p = mk.pair(mk.val(1), mk.val(2))
      local x = mk.var()
      local v = mk.val(5)
      
      assert.is_true(mk.is_pair(p))
      assert.is_false(mk.is_pair(x))
      assert.is_false(mk.is_pair(v))
    end)
    
    it("should nest pairs to represent lists", function()
      local lst = make_list({1, 2, 3})
      
      assert.are.equal("pair", lst.type)
      assert.are.equal(1, lst.left.value)
      assert.are.equal("pair", lst.right.type)
      assert.are.equal(2, lst.right.left.value)
      assert.are.equal("pair", lst.right.right.type)
      assert.are.equal(3, lst.right.right.left.value)
      assert.are.equal("val", lst.right.right.right.type)
      assert.is_nil(lst.right.right.right.value)
    end)
  end)
end)