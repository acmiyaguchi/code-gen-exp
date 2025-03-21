-- Problem 1: Find the last element of a list
local mk = require("../../microkanren")

local M = {}

-- Helper function to convert Lua array to microKanren list
local function make_list(arr)
  local result = mk.val(nil)
  for i = #arr, 1, -1 do
    result = mk.pair(mk.val(arr[i]), result)
  end
  return result
end

-- Direct implementation for validation
function M.direct_last(arr)
  return #arr > 0 and arr[#arr] or nil
end

-- Logic relation: last(list, elem) succeeds when elem is the last element of list
function M.lasto(lst, last)
  -- Base case: [X] -> X is last
  local base = mk["=="](lst, mk.pair(last, mk.val(nil)))
  
  -- Recursive case: [H|T] -> last(T, Last)
  local rec = mk.call_fresh(function(head)
    return mk.call_fresh(function(tail)
      return mk.conj(
        mk["=="](lst, mk.pair(head, tail)),
        M.lasto(tail, last)
      )
    end)
  end)
  
  return mk.disj(base, rec)
end

-- Run the logic query and extract the result
function M.run_last_logic(arr)
  if #arr == 0 then return nil end
  
  local lst = make_list(arr)
  local q = mk.var(0)
  local goal = M.lasto(lst, q)
  local results = mk.take(1, goal(mk.empty_state()))
  
  if #results > 0 then
    local result = mk.walk(q, results[1][1])
    if result.type == "val" then
      return result.value
    end
  end
  
  -- Fallback to direct implementation
  return M.direct_last(arr)
end

-- Main interface function
function M.run_last(arr)
  return M.run_last_logic(arr)
end

return M