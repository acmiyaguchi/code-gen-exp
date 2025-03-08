-- Unit tests for API module with mocked HTTPS

local busted = require("busted")
local describe = busted.describe
local it = busted.it
local assert = require("luassert")
local spy = require("luassert.spy")
local mock = require("luassert.mock")

-- Setup path
package.path = "../?.lua;" .. package.path

-- Load utils first for JSON handling
local utils = require("utils")

-- Create a proper mock response handler
local function mockJsonResponse(data)
  local jsonStr
  if type(data) == "table" then
    -- Simple table to JSON conversion for test data
    if #data > 0 then
      -- It's an array
      jsonStr = "["
      for i, v in ipairs(data) do
        jsonStr = jsonStr .. tostring(v)
        if i < #data then jsonStr = jsonStr .. "," end
      end
      jsonStr = jsonStr .. "]"
    else
      -- It's an object
      jsonStr = "{"
      local first = true
      for k, v in pairs(data) do
        if not first then jsonStr = jsonStr .. "," end
        first = false
        
        if type(v) == "string" then
          jsonStr = jsonStr .. '"' .. k .. '":"' .. v .. '"'
        else
          jsonStr = jsonStr .. '"' .. k .. '":' .. tostring(v)
        end
      end
      jsonStr = jsonStr .. "}"
    end
  else
    jsonStr = tostring(data)
  end
  
  return jsonStr
end

-- Mock the https module
local https = mock({
  request = function(url, callback) 
    -- Return mock data based on URL
    if url:match("topstories") then
      callback(mockJsonResponse({1,2,3,4,5}), 200, {})
    elseif url:match("/item/1%.json") then
      callback(mockJsonResponse({
        id = 1,
        title = "Test Story",
        by = "user",
        score = 100,
        time = 1630000000,
        type = "story"
      }), 200, {})
    else
      callback(mockJsonResponse({}), 200, {})
    end
  end,
  update = function() end,
  init = function() end,
  isUsingMockData = function() return false end
})

-- Use a custom require function to inject our mock
local old_require = require
_G.require = function(mod)
  if mod == "https" then
    return https
  else
    return old_require(mod)
  end
end

-- Now load the API module with our mock in place
local api = require("api")

-- Helper function to trigger callbacks immediately
local function executeCallbacks()
  -- The mock HTTPS module calls callbacks immediately in this test,
  -- so we don't need to do anything here
end

describe("API module", function()
  describe("fetchTopStories", function()
    it("should fetch and return stories with pagination", function()
      local result
      
      api.fetchTopStories(function(success, data)
        result = { success = success, data = data }
      end, 1)
      
      -- Wait for callbacks to complete
      executeCallbacks()
      
      -- Check if callback was called with success
      assert.truthy(result)
      assert.truthy(result.success)
      assert.truthy(result.data)
      assert.equals(1, result.data.page)
      assert.equals(1, result.data.totalPages)
    end)
  end)
  
  describe("fetchItem", function()
    it("should fetch an item by ID", function()
      local result
      
      api.fetchItem(1, function(success, item)
        result = { success = success, item = item }
      end)
      
      -- Wait for callbacks to complete
      executeCallbacks()
      
      -- Check callback result
      assert.truthy(result)
      assert.truthy(result.success)
      assert.truthy(result.item)
      assert.equals(1, result.item.id)
      assert.equals("Test Story", result.item.title)
    end)
  end)
end)
