local problem1 = require("problems.p01.main")

describe("Problem 01: Find the last element of a list", function()
  -- Test cases
  local test_cases = {
    -- Basic cases
    {input = {1}, expected = 1, description = "single element list"},
    {input = {1, 2, 3, 4, 5}, expected = 5, description = "simple list with positive integers"},
    {input = {9, 8, 7}, expected = 7, description = "descending list"},
    {input = {42}, expected = 42, description = "another single element list"},
    
    -- More diverse cases
    {input = {-1, -2, -3}, expected = -3, description = "negative numbers"},
    {input = {0, 0, 0, 1}, expected = 1, description = "list with zeros"},
    {input = {3.14, 2.71, 1.618}, expected = 1.618, description = "floating point numbers"},
    {input = {"a", "b", "c", "d"}, expected = "d", description = "string elements"},
    {input = {true, false, true}, expected = true, description = "boolean elements"},
  }
  
  -- Tests for the direct implementation (for reference)
  describe("Direct implementation", function()
    it("should find the last element correctly", function()
      for i, test in ipairs(test_cases) do
        local result = problem1.direct_last(test.input)
        assert.are.equal(test.expected, result, 
          string.format("Test case %d (%s) failed", i, test.description))
      end
    end)
    
    it("should handle empty list", function()
      assert.is_nil(problem1.direct_last({}))
    end)
  end)
  
  -- Tests for the logic-based implementation
  describe("Logic-based implementation", function()
    it("should find the last element correctly", function()
      for i, test in ipairs(test_cases) do
        local result = problem1.run_last_logic(test.input)
        assert.are.equal(test.expected, result, 
          string.format("Test case %d (%s) failed", i, test.description))
      end
    end)
    
    it("should handle empty list", function()
      assert.is_nil(problem1.run_last_logic({}))
    end)
  end)
  
  -- Tests for the main interface function
  describe("Primary run_last function", function()
    it("should use the logic-based implementation by default", function()
      for _, test in ipairs(test_cases) do
        local result = problem1.run_last(test.input)
        assert.are.equal(test.expected, result)
      end
    end)
  end)
  
  -- Test that both implementations produce identical results
  describe("Implementation comparison", function()
    it("should produce identical results for both implementations", function()
      for _, test in ipairs(test_cases) do
        local direct_result = problem1.direct_last(test.input)
        local logic_result = problem1.run_last_logic(test.input)
        assert.are.equal(direct_result, logic_result)
      end
    end)
  end)
end)