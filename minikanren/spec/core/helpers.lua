local mk = require("microkanren")

-- Helper functions for testing
local M = {}

function M.make_list(arr)
  local result = mk.val(nil)  -- Explicit nil for end of list
  for i = #arr, 1, -1 do
    result = mk.pair(mk.val(arr[i]), result)
  end
  return result
end

function M.list_to_array(lst, s)
  local result = {}
  local current = lst
  
  while current and current.type == "pair" do
    local head = mk.walk(current.left, s or {})
    if head.type == "val" then
      table.insert(result, head.value)
    end
    current = mk.walk(current.right, s or {})
  end
  
  return result
end

return M