local mk = require("microkanren")

describe("Substitutions and Walking", function()
  it("should walk a variable to its value", function()
    local x = mk.var(1)
    local y = mk.var(2)
    local s = {{x, mk.val(5)}}
    
    local result = mk.walk(x, s)
    assert.are.equal("val", result.type)
    assert.are.equal(5, result.value)
    
    -- Unbound variable returns itself
    local result2 = mk.walk(y, s)
    assert.are.equal("var", result2.type)
    assert.are.equal(2, result2.id)
  end)
  
  it("should walk through variable chains", function()
    local x = mk.var(1)
    local y = mk.var(2)
    local z = mk.var(3)
    
    -- Create a chain x -> y -> z -> 42
    local s = {
      {x, y},
      {y, z},
      {z, mk.val(42)}
    }
    
    local result = mk.walk(x, s)
    assert.are.equal("val", result.type)
    assert.are.equal(42, result.value)
  end)
  
  it("should extend substitutions", function()
    local x = mk.var(1)
    local y = mk.var(2)
    local s = {}
    
    local s1 = mk.ext_s(x, mk.val(5), s)
    assert.are.equal(1, #s1)
    
    local s2 = mk.ext_s(y, mk.val(10), s1)
    assert.are.equal(2, #s2)
    
    -- Check that we can retrieve values
    assert.are.equal(5, mk.walk(x, s2).value)
    assert.are.equal(10, mk.walk(y, s2).value)
  end)
end)