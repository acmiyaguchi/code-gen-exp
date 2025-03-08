-- Utility functions

local utils = {}

-- Convert Unix timestamp to "time ago" string
function utils.timeAgo(timestamp)
    if not timestamp then return "unknown time" end
    
    local now = os.time()
    local diff = now - timestamp
    
    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        local mins = math.floor(diff / 60)
        return mins .. " minute" .. (mins > 1 and "s" or "") .. " ago"
    elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        return hours .. " hour" .. (hours > 1 and "s" or "") .. " ago"
    elseif diff < 2592000 then
        local days = math.floor(diff / 86400)
        return days .. " day" .. (days > 1 and "s" or "") .. " ago"
    else
        local months = math.floor(diff / 2592000)
        return months .. " month" .. (months > 1 and "s" or "") .. " ago"
    end
end

-- Extract hostname from URL
function utils.getHostname(url)
    if not url then return "No URL" end
    
    local hostname = url:match("://([^/]+)")
    if not hostname then
        hostname = url:match("^([^/]+)")
    end
    
    return hostname or "Unknown"
end

-- Format comment text (basic HTML stripping)
function utils.formatCommentText(text)
    if not text then return "" end
    
    -- Replace common HTML entities
    text = text:gsub("&gt;", ">")
    text = text:gsub("&lt;", "<")
    text = text:gsub("&amp;", "&")
    text = text:gsub("&quot;", "\"")
    text = text:gsub("&#x27;", "'")
    
    -- Strip HTML tags (simple approach)
    text = text:gsub("<[^>]+>", "")
    
    -- Trim whitespace
    text = text:gsub("^%s*(.-)%s*$", "%1")
    
    return text
end

-- Performance logging function with timestamps
function utils.logPerformance(message)
  local time = love.timer.getTime()
  print(string.format("[%.3fs] %s", time, message))
end

-- Performance logging function with thresholds
function utils.logPerformanceIf(condition, message)
  if condition then
    utils.logPerformance(message)
  end
end

-- Create a simple JSON module for our mock data
local json = {}

-- Simple JSON parser that can handle our mock responses
function json.decode(str)
    -- Handle arrays of numbers (top stories list)
    if str:match("^%s*%[%s*%d+") then
        local result = {}
        for id in str:gmatch("%d+") do
            table.insert(result, tonumber(id))
        end
        return result
    end
    
    -- Handle simple objects (story and comment data)
    if str:match("^%s*{") then
        local result = {}
        
        -- Extract type to determine object structure
        local objType = str:match('"type":"(%w+)"')
        
        if objType == "story" then
            result.id = tonumber(str:match('"id":(%d+)'))
            result.title = str:match('"title":"([^"]+)"')
            result.by = str:match('"by":"([^"]+)"')
            result.score = tonumber(str:match('"score":(%d+)'))
            result.time = tonumber(str:match('"time":(%d+)'))
            result.url = str:match('"url":"([^"]+)"')
            result.type = "story"
            
            -- Extract kids if present
            local kidsStr = str:match('"kids":%[([^]]+)%]')
            if kidsStr then
                result.kids = {}
                for kid in kidsStr:gmatch("%d+") do
                    table.insert(result.kids, tonumber(kid))
                end
            end
        elseif objType == "comment" then
            result.id = tonumber(str:match('"id":(%d+)'))
            result.by = str:match('"by":"([^"]+)"')
            result.time = tonumber(str:match('"time":(%d+)'))
            result.parent = tonumber(str:match('"parent":(%d+)'))
            result.text = str:match('"text":"([^"]+)"')
            result.type = "comment"
        end
        
        return result
    end
    
    -- Default for empty or invalid JSON
    return {}
end

-- Add json module to utils
utils.json = json

return utils
