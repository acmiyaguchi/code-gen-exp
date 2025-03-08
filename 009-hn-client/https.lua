-- Mock HTTPS module for LÖVE2D 11.5 (no external dependencies)

local https = {}

-- We'll always use mock data since we don't have lua-https in LÖVE 11.5
local useMockData = true

-- Request queue for simulating asynchronous behavior
local requestQueue = {}

-- Mock data for API responses
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

-- Simulate async requests using a request queue
function https.request(url, callback)
    -- Add the request to the queue to be processed during update
    table.insert(requestQueue, {
        url = url,
        callback = callback,
        delay = 0.2, -- Simulate network delay
        timeRemaining = 0.2
    })
end

-- Process queued requests
function https.update(dt)
    if #requestQueue == 0 then
        return
    end
    
    -- Process requests in the queue
    local i = 1
    while i <= #requestQueue do
        local request = requestQueue[i]
        
        -- Decrease the time remaining for this request
        request.timeRemaining = request.timeRemaining - dt
        
        -- If the delay has elapsed, process the request
        if request.timeRemaining <= 0 then
            local url = request.url
            local callback = request.callback
            
            -- Process the request based on URL
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
            
            -- Remove the request from the queue
            table.remove(requestQueue, i)
        else
            i = i + 1
        end
    end
end

-- These functions remain for API compatibility
function https.init() 
    print("Using sample data (LÖVE 11.5 compatible mode)")
end
function https.useMockData() end
function https.isUsingMockData() return true end

return https