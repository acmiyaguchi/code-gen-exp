-- Problem 1: Find the last element of a list
local mk = require("../../microkanren")

local M = {}

-- Helper functions for list operations
local function make_list(arr)
  local result = nil
  for i = #arr, 1, -1 do
    result = mk.pair(mk.val(arr[i]), result or mk.val(nil))
  end
  return result
end

-- Helper function for debugging
local function print_list(lst, s)
  local result = "("
  local current = lst
  
  while current and current.type == "pair" do
    local head = mk.walk(current.left, s or {})
    if head.type == "val" then
      result = result .. tostring(head.value)
    else
      result = result .. "var"
    end
    
    current = mk.walk(current.right, s or {})
    if current and current.type == "pair" then
      result = result .. " "
    end
  end
  
  return result .. ")"
end

local function list_to_array(lst, s)
  local result = {}
  local current = lst
  
  while current and current.type == "pair" do
    local head = mk.walk(current.left, s)
    table.insert(result, head.value)
    current = mk.walk(current.right, s)
  end
  
  return result
end

-- A much simpler implementation of last_element that should work correctly
function M.last_element(lst, last)
  -- Special case for empty list - always fails
  local empty_list_case = mk.conj(
    mk["=="](lst, mk.val(nil)),
    mk["=="](mk.val(false), mk.val(true)) -- Always fails
  )
  
  -- Case for a single element list
  local singleton_case = mk.conj(
    mk["=="](lst, mk.pair(last, mk.val(nil))),
    mk["=="](mk.val(true), mk.val(true)) -- Always succeeds
  )
  
  -- Case for a list with at least 2 elements
  local recursive_case = mk.call_fresh(function(head)
    return mk.call_fresh(function(tail)
      return mk.conj(
        -- Assert lst = (head . tail)
        mk["=="](lst, mk.pair(head, tail)),
        -- And check if last element is in tail
        mk.call_fresh(function(_)
          return M.last_element(tail, last)
        end)
      )
    end)
  end)
  
  -- Try each case in order
  return mk.disj(
    singleton_case,
    recursive_case
  )
end

-- Helper function to run the last_element goal
function M.run_last(arr)
  if #arr == 0 then
    return nil -- Empty list has no last element
  end
  
  -- For single element list, shortcut
  if #arr == 1 then
    return arr[1]
  end
  
  local lst = make_list(arr)
  local last_var = mk.var(0)
  
  local state = mk.empty_state()
  local stream = M.last_element(lst, last_var)(state)
  
  -- Take multiple results in case of streaming delays
  local results = mk.take(5, stream)
  
  if #results > 0 then
    local result = mk.walk(last_var, results[1][1])
    if result.type == "val" then
      return result.value
    end
  end
  
  -- For debugging
  print("Failed to find last element of list:", table.concat(arr, ", "))
  return nil
end

return M
