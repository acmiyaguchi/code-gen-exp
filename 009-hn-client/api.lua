-- Hacker News API interface (refactored)

local api = {}
local https = require("https")
local utils = require("utils")

-- API configuration
local config = {
  baseUrl = "https://hacker-news.firebaseio.com/v0/",
  storiesPerPage = 10,
  maxComments = 20
}

-- URL helpers
local urls = {
  topStories = config.baseUrl .. "topstories.json",
  item = function(id) return config.baseUrl .. "item/" .. id .. ".json" end
}

-- Generic error handler for API responses
local function handleApiResponse(data, code, headers, callback)
  if code ~= 200 then
    callback(false, "HTTP error: " .. tostring(code))
    return false
  end
  
  local success, result = pcall(function() return utils.json.decode(data) end)
  if not success or type(result) ~= "table" then
    callback(false, "Failed to parse API response")
    return false
  end
  
  return result
end

-- Fetch top stories with pagination
function api.fetchTopStories(callback, page)
  page = page or 1
  
  https.request(urls.topStories, function(data, code, headers)
    local storyIds = handleApiResponse(data, code, headers, callback)
    if not storyIds then return end
    
    -- Calculate pagination
    local startIndex = (page - 1) * config.storiesPerPage + 1
    local endIndex = math.min(startIndex + config.storiesPerPage - 1, #storyIds)
    local totalPages = math.ceil(#storyIds / config.storiesPerPage)
    
    -- Batch fetch stories for this page
    api.batchFetchItems(
      storyIds, 
      startIndex, 
      endIndex, 
      function(items) 
        -- Filter out non-stories
        local stories = {}
        for _, item in ipairs(items) do
          if item and item.type == "story" then
            table.insert(stories, item)
          end
        end
        
        -- Sort by score
        table.sort(stories, function(a, b) return (a.score or 0) > (b.score or 0) end)
        
        -- Return with pagination info
        callback(true, {
          items = stories,
          page = page,
          totalPages = totalPages,
          hasNextPage = page < totalPages,
          hasPrevPage = page > 1
        })
      end
    )
  end)
end

-- Fetch a batch of items by ID range
function api.batchFetchItems(itemIds, startIndex, endIndex, callback)
  local items = {}
  local loaded = 0
  local toLoad = endIndex - startIndex + 1
  
  for i = startIndex, endIndex do
    local id = itemIds[i]
    api.fetchItem(id, function(success, item)
      if success and item then
        items[#items + 1] = item
      end
      
      loaded = loaded + 1
      if loaded == toLoad then
        callback(items)
      end
    end)
  end
end

-- Fetch individual item (story/comment)
function api.fetchItem(id, callback)
  https.request(urls.item(id), function(data, code, headers)
    local item = handleApiResponse(data, code, headers, callback)
    if item then callback(true, item) end
  end)
end

-- Fetch story details (alias for fetchItem for stories)
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
    
    -- Get comment IDs
    local commentIds = story.kids or {}
    if #commentIds == 0 then
      callback(true, {})
      return
    end
    
    -- Limit comments
    local commentsToFetch = {}
    for i = 1, math.min(config.maxComments, #commentIds) do
      table.insert(commentsToFetch, commentIds[i])
    end
    
    -- Batch fetch comments
    api.batchFetchItems(
      commentsToFetch, 
      1, 
      #commentsToFetch, 
      function(comments)
        -- Filter out deleted/dead comments
        local validComments = {}
        for _, comment in ipairs(comments) do
          if comment and not comment.deleted and not comment.dead then
            table.insert(validComments, comment)
          end
        end
        
        -- Sort by timestamp (newest first)
        table.sort(validComments, function(a, b) return (a.time or 0) > (b.time or 0) end)
        
        callback(true, validComments)
      end
    )
  end)
end

return api
