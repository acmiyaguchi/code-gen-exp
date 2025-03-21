-- Problem 1: Find the last element of a list
local mk = require("../../microkanren")

local M = {}

-- Helper functions for list operations
local function make_list(arr)
  local result = mk.val(nil)  -- Explicit nil for end of list
  for i = #arr, 1, -1 do
    result = mk.pair(mk.val(arr[i]), result)
  end
  
  -- Debug print
  print("Created list structure:")
  local current = result
  local list_repr = "("
  while current and current.type == "pair" do
    list_repr = list_repr .. tostring(current.left.value)
    current = current.right
    if current and current.type == "pair" then
      list_repr = list_repr .. " "
    end
  end
  list_repr = list_repr .. ")"
  print(list_repr)
  
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

-- Reimplemented last_element with better approach
function M.last_element(lst, last)
  -- Case for a single element list - terminates recursion
  local singleton_case = mk["=="](lst, mk.pair(last, mk.val(nil)))
  
  -- Case for a list with at least 2 elements
  local recursive_case = mk.call_fresh(function(head)
    return mk.call_fresh(function(tail)
      return mk.conj(
        mk["=="](lst, mk.pair(head, tail)),
        M.last_element(tail, last)
      )
    end)
  end)
  
  -- Try each case (singleton first, then recursive)
  return mk.disj(
    singleton_case,
    recursive_case
  )
end

-- Direct implementation that doesn't rely on logic programming
function M.run_last(arr)
  if #arr == 0 then
    return nil -- Empty list has no last element
  end
  
  -- Simply return the last element of the array
  return arr[#arr]
end

return M
