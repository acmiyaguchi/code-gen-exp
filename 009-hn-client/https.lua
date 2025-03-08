-- HTTPS request module using LuaSocket and LuaSec (refactored)

local https = {}

-- Configuration
local config = {
  maxRetries = 2,
  requestTimeout = 10,
  mockDelay = 0.2
}

-- State
local state = {
  useMockData = false,
  requestQueue = {}
}

-- Try to load external libraries
local function loadLibraries()
  local socket = require("socket") -- Socket always required
  
  -- Try to load HTTP/HTTPS libraries
  local http, https_lib
  local success = pcall(function()
    http = require("socket.http")
    https_lib = require("ssl.https")
    require("ltn12")
    return true
  end)
  
  if not success then
    print("Warning: LuaSocket/LuaSec libraries not found. Using mock data.")
    state.useMockData = true
    return false
  end
  
  return true, http, https_lib
end

-- Mock data for fallback mode
local mockData = {
  -- ...existing mock data...
}

-- Enhanced mock data preparation
local function initMockData()
  -- Top stories
  mockData.topstories = "[9129911,9129199,9127761,9128141,9128264,9127792,9129248,9127092,9128367]"
  
  -- Create base stories
  mockData.items = {
    ["9129911"] = {
      id = 9129911,
      title = "[Sample] Show HN: A Love2D Project",
      by = "demousername",
      score = 71,
      time = os.time() - 3600,
      kids = {9129929, 9129932, 9129954, 9130130},
      url = "http://example.com/",
      type = "story"
    },
    -- ...other base items...
  }
  
  -- Generate additional mock items
  for i = 2, 10 do
    local baseId = 9129911 + i
    mockData.items[tostring(baseId)] = {
      id = baseId,
      title = "Sample story #" .. i,
      by = "user" .. i,
      score = math.random(10, 200),
      time = os.time() - math.random(3600, 86400),
      url = "http://example.com/story" .. i,
      type = "story"
    }
    
    -- Add comments to each story
    local kids = {}
    local numComments = math.random(2, 5)
    for j = 1, numComments do
      local commentId = baseId + j * 100
      kids[j] = commentId
      mockData.items[tostring(commentId)] = {
        id = commentId,
        text = "This is comment #" .. j .. " on story #" .. i,
        by = "commenter" .. i .. "_" .. j,
        time = os.time() - math.random(100, 3600),
        parent = baseId,
        type = "comment"
      }
    end
    mockData.items[tostring(baseId)].kids = kids
  end
end

-- Create JSON for mock item
local function getMockJsonForItem(item)
  if not item then return "{}" end
  
  local jsonStr
  
  if item.type == "story" then
    jsonStr = string.format([[{"id":%d,"title":"%s","by":"%s","score":%d,"time":%d,"url":"%s","type":"story"}]],
      item.id, item.title, item.by, item.score, item.time, item.url or ""
    )
    
    -- Add kids array if present
    if item.kids and #item.kids > 0 then
      local kidsStr = "["
      for i, kid in ipairs(item.kids) do
        kidsStr = kidsStr .. kid
        if i < #item.kids then
          kidsStr = kidsStr .. ","
        end
      end
      kidsStr = kidsStr .. "]"
      
      -- Insert kids array before closing brace
      jsonStr = jsonStr:sub(1, -2) .. ',"kids":' .. kidsStr .. "}"
    end
  elseif item.type == "comment" then
    jsonStr = string.format([[{"id":%d,"text":"%s","by":"%s","time":%d,"parent":%d,"type":"comment"}]],
      item.id, (item.text or ""):gsub('"', '\\"'), item.by, item.time, item.parent or 0
    )
  end
  
  return jsonStr or "{}"
end

-- Process a mock request
local function processMockRequest(request)
  local url = request.url
  local callback = request.callback
  
  -- Return appropriate mock data based on URL
  if url:match("topstories") then
    callback(mockData.topstories, 200, {})
  elseif url:match("/item/") then
    local id = url:match("/item/(%d+)%.json")
    local item = mockData.items[id]
    local jsonStr = getMockJsonForItem(item)
    callback(jsonStr, 200, {})
  else
    callback("{}", 404, {})
  end
end

-- Make a real HTTP request
local function makeRealRequest(url, callback, libraries)
  local http, https_lib, ltn12 = libraries.http, libraries.https, libraries.ltn12
  local responseBody = {}
  
  -- Choose client based on protocol
  local client = http
  if url:match("^https://") then
    client = https_lib
  end
  
  -- Create request in a separate coroutine to avoid blocking
  local co = coroutine.create(function()
    local result, code, headers = client.request{
      url = url,
      sink = ltn12.sink.table(responseBody),
      headers = {
        ["User-Agent"] = "Love2D-HackerNewsClient/1.0"
      },
      timeout = config.requestTimeout
    }
    
    local response = table.concat(responseBody)
    
    if code == 200 then
      callback(response, code, headers)
    else
      callback("", code or 0, headers, "HTTP error: " .. (code or "unknown"))
    end
  end)
  
  -- Add the coroutine to our queue
  table.insert(state.requestQueue, {
    type = "coroutine",
    co = co
  })
end

-- Initialize the HTTPS module
function https.init()
  -- Initialize mock data
  initMockData()
  
  -- Try to load libraries
  local success, http, https_lib = loadLibraries()
  
  if state.useMockData then
    print("Using sample data (LuaSocket/LuaSec not available)")
  else
    print("HTTPS module initialized with LuaSocket/LuaSec")
    
    -- Store libraries for later use
    state.libraries = {
      http = http,
      https = https_lib,
      ltn12 = require("ltn12")
    }
  end
end

-- Make an HTTP request
function https.request(url, callback, retryCount)
  if state.useMockData then
    -- Add mock request to queue with a delay
    table.insert(state.requestQueue, {
      type = "mock",
      url = url,
      callback = callback,
      delay = config.mockDelay,
      timeRemaining = config.mockDelay
    })
    return
  end
  
  -- Try to make a real HTTP request
  local ok, err = pcall(function()
    makeRealRequest(url, function(data, code, headers, errorMsg)
      if code == 200 then
        callback(data, code, headers)
      else
        -- If request failed and we haven't reached max retries yet, try again
        if (retryCount or 0) < config.maxRetries then
          print("Request failed: " .. (errorMsg or "Unknown error") .. " - Retrying...")
          https.request(url, callback, (retryCount or 0) + 1)
        else
          -- If max retries reached, switch to mock mode
          print("Max retries reached. Falling back to mock data.")
          state.useMockData = true
          https.request(url, callback, 0)
        end
      end
    end, state.libraries)
  end)
  
  if not ok then
    print("Error making request: " .. tostring(err))
    state.useMockData = true
    https.request(url, callback, 0)
  end
end

-- Process queued requests
function https.update(dt)
  -- Process the queue
  local i = 1
  while i <= #state.requestQueue do
    local request = state.requestQueue[i]
    
    if request.type == "mock" then
      -- Update delay for mock requests
      request.timeRemaining = request.timeRemaining - dt
      
      -- If delay is done, process the mock request
      if request.timeRemaining <= 0 then
        processMockRequest(request)
        table.remove(state.requestQueue, i)
      else
        i = i + 1
      end
    elseif request.type == "coroutine" then
      -- Handle coroutines (for real requests)
      if coroutine.status(request.co) == "suspended" then
        local ok, err = coroutine.resume(request.co)
        if not ok then
          print("Coroutine error: " .. tostring(err))
          table.remove(state.requestQueue, i)
        else
          i = i + 1
        end
      else
        table.remove(state.requestQueue, i)
      end
    else
      i = i + 1
    end
  end
end

-- Force switch to mock data mode
function https.useMockData()
  state.useMockData = true
  print("Switched to mock data mode")
end

-- Check if we're using mock data mode
function https.isUsingMockData()
  return state.useMockData
end

return https