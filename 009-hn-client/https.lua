-- HTTPS request module using LuaSocket and LuaSec

local https = {}

-- Flag to track if we're using mock data (fallback mode)
local useMockData = false

-- Load required libraries
local socket = require("socket")
local http, https_lib
local success = pcall(function()
    http = require("socket.http")
    https_lib = require("ssl.https")
    require("ltn12")
    return true
end)

-- If libraries couldn't be loaded, fall back to mock data
if not success then
    print("Warning: LuaSocket/LuaSec libraries not found. Using mock data.")
    useMockData = true
end

-- Queue to handle both real and mock requests
local requestQueue = {}

-- Mock data for fallback mode
local mockData = {
    topstories = "[9129911,9129199,9127761,9128141,9128264,9127792,9129248,9127092,9128367]",
    items = {
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
        ["9129199"] = {
            id = 9129199,
            title = "The future of Lua programming",
            by = "luadev",
            score = 103,
            time = os.time() - 7200,
            kids = {9129201, 9129203},
            url = "http://tech-blog.example.com/future",
            type = "story"
        },
        ["9127761"] = {
            id = 9127761,
            title = "Announcing a new game engine",
            by = "gamedev",
            score = 88,
            time = os.time() - 28800,
            kids = {9127780, 9127790, 9127810},
            url = "http://github.example.com/engine",
            type = "story"
        },
        ["9129929"] = {
            id = 9129929,
            text = "This is a sample comment. It might contain some formatting that needs to be handled properly.",
            by = "commenter1",
            time = os.time() - 3000,
            parent = 9129911,
            type = "comment"
        },
        ["9129932"] = {
            id = 9129932,
            text = "Another comment with different content. Some comments can be quite long and need proper wrapping.",
            by = "commenter2",
            time = os.time() - 2800,
            parent = 9129911,
            type = "comment"
        },
        ["9129954"] = {
            id = 9129954,
            text = "A third comment to demonstrate threading. This would be shown with the others.",
            by = "commenter3",
            time = os.time() - 2500,
            parent = 9129911,
            type = "comment"
        },
        ["9130130"] = {
            id = 9130130,
            text = "Final comment for the first story. Four comments should be enough for demonstration.",
            by = "commenter4",
            time = os.time() - 1800,
            parent = 9129911,
            type = "comment"
        }
    }
}

-- Add more mock items for the rest of the stories
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
    
    -- Add some comments to each story
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

-- Modified version of makeRealRequest to use our queue system
local function makeRealRequest(url, callback)
    local responseBody = {}
    
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
            timeout = 10
        }
        
        local response = table.concat(responseBody)
        
        if code == 200 then
            callback(response, code, headers)
        else
            callback("", code or 0, headers, "HTTP error: " .. (code or "unknown"))
        end
    end)
    
    -- Add the coroutine to our queue
    table.insert(requestQueue, {
        type = "coroutine",
        co = co
    })
end

-- Queue a new HTTP request
function https.request(url, callback, retryCount)
    if useMockData then
        -- Add mock request to queue with a delay
        table.insert(requestQueue, {
            type = "mock",
            url = url,
            callback = callback,
            delay = 0.2,  -- Simulate network delay
            timeRemaining = 0.2
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
                if (retryCount or 0) < 2 then
                    print("Request failed: " .. (errorMsg or "Unknown error") .. " - Retrying...")
                    https.request(url, callback, (retryCount or 0) + 1)
                else
                    -- If max retries reached, switch to mock mode
                    print("Max retries reached. Falling back to mock data.")
                    useMockData = true
                    https.request(url, callback, 0)
                end
            end
        end)
    end)
    
    if not ok then
        print("Error making request: " .. tostring(err))
        useMockData = true
        https.request(url, callback, 0)
    end
end

-- Process queued requests
function https.update(dt)
    -- Process mock requests
    local i = 1
    while i <= #requestQueue do
        local request = requestQueue[i]
        
        if request.type == "mock" then
            -- Update delay
            request.timeRemaining = request.timeRemaining - dt
            
            -- If delay is done, process the mock request
            if request.timeRemaining <= 0 then
                local url = request.url
                local callback = request.callback
                
                -- Handle mock data
                if url:match("topstories") then
                    callback(mockData.topstories, 200, {})
                elseif url:match("/item/") then
                    local id = url:match("/item/(%d+)%.json")
                    
                    if mockData.items[id] then
                        -- Convert mock item to JSON string
                        local item = mockData.items[id]
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
                        
                        if jsonStr then
                            callback(jsonStr, 200, {})
                        else
                            callback("{}", 200, {})
                        end
                    else
                        callback("{}", 200, {})
                    end
                else
                    callback("{}", 404, {})
                end
                
                table.remove(requestQueue, i)
            else
                i = i + 1
            end
        elseif request.type == "coroutine" then
            -- Handle coroutines (for real requests)
            if coroutine.status(request.co) == "suspended" then
                local ok, err = coroutine.resume(request.co)
                if not ok then
                    print("Coroutine error: " .. tostring(err))
                    table.remove(requestQueue, i)
                else
                    i = i + 1
                end
            else
                table.remove(requestQueue, i)
            end
        else
            i = i + 1
        end
    end
end

-- Force switch to mock data mode
function https.useMockData()
    useMockData = true
    print("Switched to mock data mode")
end

-- Check if we're using mock data mode
function https.isUsingMockData()
    return useMockData
end

-- Initialize module
function https.init() 
    if useMockData then
        print("Using sample data (LuaSocket/LuaSec not available)")
    else
        print("HTTPS module initialized with LuaSocket/LuaSec")
    end
end

return https