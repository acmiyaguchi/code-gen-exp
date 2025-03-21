local mk = require("microkanren")
local helpers = require("spec.core.helpers")
local make_list = helpers.make_list

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
    
    -- Both variables should now point to 10
    local result_x = mk.walk(x, s3)
    local result_y = mk.walk(y, s3)
    assert.are.equal(10, result_x.value)
    assert.are.equal(10, result_y.value)
  end)
  
  it("should allow unification in either direction", function()
    local x = mk.var(1)
    
    -- Test var with val and val with var
    local s1 = mk.unify(x, mk.val(5), {})
    local s2 = mk.unify(mk.val(7), mk.var(2), {})
    
    assert.are.equal(5, mk.walk(x, s1).value)
    assert.are.equal(7, mk.walk(mk.var(2), s2).value)
  end)
  
  it("should unify identical values", function()
    local s = mk.unify(mk.val(42), mk.val(42), {})
    assert.is_not_nil(s)
    assert.are.equal(0, #s)  -- No new bindings needed
  end)
  
  it("should fail to unify different constants", function()
    local s = mk.unify(mk.val(1), mk.val(2), {})
    assert.is_nil(s)
  end)
  
  it("should unify nested pairs (lists)", function()
    local list1 = make_list({1, 2, 3})
    local list2 = make_list({1, 2, 3})
    
    -- Same lists should unify
    local s1 = mk.unify(list1, list2, {})
    assert.is_not_nil(s1)
    
    -- Lists with different elements should not unify
    local list3 = make_list({1, 2, 4})
    local s2 = mk.unify(list1, list3, {})
    assert.is_nil(s2)
    
    -- List with variables should unify and bind variables
    local x = mk.var(1)
    local list4 = mk.pair(mk.val(1), mk.pair(mk.val(2), mk.pair(x, mk.val(nil))))
    local s3 = mk.unify(list4, list1, {})
    assert.is_not_nil(s3)
    assert.are.equal(1, #s3)
    assert.are.equal(3, mk.walk(x, s3).value)
  end)
  
  it("should handle variable occurrence check (triangle case)", function()
    local x = mk.var(1)
    
    -- Try to unify x with a pair containing x
    -- This would create an infinite recursive structure
    local p = mk.pair(mk.val(5), x)
    
    -- This should fail with a proper occurrence check
    -- Note: the current implementation doesn't perform occurrence check
    -- so this test is marked as pending
    pending("should implement variable occurrence check")
  end)
end)