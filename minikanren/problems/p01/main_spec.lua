local problem1 = require("problems.p01.main")

-- Test the last element function
local function test_last_element()
  local test_cases = {
    {input = {1}, expected = 1},
    {input = {1, 2, 3, 4, 5}, expected = 5},
    {input = {9, 8, 7}, expected = 7},
    {input = {42}, expected = 42},
  }
  
  for i, test in ipairs(test_cases) do
    local result = problem1.run_last(test.input)
    assert(result == test.expected, 
           string.format("Test case %d failed: expected %s, got %s", 
                         i, tostring(test.expected), tostring(result)))
  end
  
  print("All last element tests passed!")
end

-- Run the test
test_last_element()
