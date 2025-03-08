-- Hacker News API interface

local api = {}
local https = require("https")
local utils = require("utils")

-- Base URLs for Hacker News API
local BASE_URL = "https://hacker-news.firebaseio.com/v0/"
local TOP_STORIES_URL = BASE_URL .. "topstories.json"
local ITEM_URL = BASE_URL .. "item/"

-- Configuration
local NUMBER_OF_STORIES = 30  -- Number of top stories to fetch
local MAX_COMMENTS = 20       -- Maximum number of comments to fetch initially

-- Fetch top stories from Hacker News
function api.fetchTopStories(callback)
    https.request(TOP_STORIES_URL, function(data, code, headers)
        if code ~= 200 then
            callback(false, "HTTP error: " .. tostring(code))
            return
        end
        
        local success, storyIds = pcall(function() return utils.json.decode(data) end)
        if not success or type(storyIds) ~= "table" then
            callback(false, "Failed to parse response")
            return
        end
        
        -- Only fetch the top N stories
        local stories = {}
        local storiesLoaded = 0
        local totalToLoad = math.min(NUMBER_OF_STORIES, #storyIds)
        
        for i = 1, totalToLoad do
            local id = storyIds[i]
            api.fetchItem(id, function(success, item)
                if success and item and item.type == "story" then
                    stories[#stories + 1] = item
                end
                
                storiesLoaded = storiesLoaded + 1
                if storiesLoaded == totalToLoad then
                    -- Sort stories by score
                    table.sort(stories, function(a, b) return (a.score or 0) > (b.score or 0) end)
                    callback(true, stories)
                end
            end)
        end
    end)
end

-- Fetch individual item (story or comment)
function api.fetchItem(id, callback)
    local url = ITEM_URL .. id .. ".json"
    https.request(url, function(data, code, headers)
        if code ~= 200 then
            callback(false, "HTTP error: " .. tostring(code))
            return
        end
        
        local success, item = pcall(function() return utils.json.decode(data) end)
        if not success or type(item) ~= "table" then
            callback(false, "Failed to parse item data")
            return
        end
        
        callback(true, item)
    end)
end

-- Fetch story details
function api.fetchStoryDetails(storyId, callback)
    api.fetchItem(storyId, callback)
end

-- Fetch story comments
function api.fetchStoryComments(storyId, callback)
    api.fetchItem(storyId, function(success, story)
        if not success or not story then
            callback(false, "Failed to fetch story")
            return
        end
        
        local comments = {}
        local commentsToFetch = {}
        
        -- Get comment IDs from the story
        if story.kids and type(story.kids) == "table" then
            for i, commentId in ipairs(story.kids) do
                if i <= MAX_COMMENTS then
                    table.insert(commentsToFetch, commentId)
                else
                    break
                end
            end
        end
        
        if #commentsToFetch == 0 then
            callback(true, {})
            return
        end
        
        local commentsLoaded = 0
        
        for _, commentId in ipairs(commentsToFetch) do
            api.fetchItem(commentId, function(success, comment)
                commentsLoaded = commentsLoaded + 1
                
                if success and comment and not comment.deleted and not comment.dead then
                    table.insert(comments, comment)
                end
                
                if commentsLoaded == #commentsToFetch then
                    -- Sort comments by creation time
                    table.sort(comments, function(a, b) return (a.time or 0) > (b.time or 0) end)
                    callback(true, comments)
                end
            end)
        end
    end)
end

return api
