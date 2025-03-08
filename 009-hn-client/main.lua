-- Hacker News Client for LÖVE2D (refactored)

-- Setup LuaRocks paths
local function setupPaths()
  local home = os.getenv("HOME")
  if home then
    package.path = home .. "/.luarocks/share/lua/5.1/?.lua;" .. 
                   home .. "/.luarocks/share/lua/5.1/?/init.lua;" .. 
                   package.path
    package.cpath = home .. "/.luarocks/lib/lua/5.1/?.so;" .. 
                    package.cpath
    print("Added LuaRocks paths to package path")
  end
end

setupPaths()

-- Import modules
local api = require("api")
local ui = require("ui")
local utils = require("utils")
local https = require("https")
local app = {}

-- Application state
app.state = {
  screen = "stories", -- "stories" or "story_detail"
  stories = {},
  pagination = {
    currentPage = 1,
    totalPages = 1,
  },
  selectedStory = nil,
  comments = {},
  ui = {
    loading = false,
    error = nil,
    scrollY = 0,
    usingMockData = false
  },
  refreshTimer = 0,
  autoRefreshInterval = 300, -- 5 minutes
  debug = {
    enableVerboseLogging = false,  -- Set to true to enable verbose logging
    frameCounter = 0,
    logInterval = 60  -- Only log every 60 frames (about once per second at 60fps)
  }
}

-- Initialize the application
function app.init()
  utils.logPerformance("Starting app initialization")
  -- Set window properties
  love.window.setTitle("Love2D Hacker News Client")
  love.window.setMode(800, 600, {resizable = true})
  love.graphics.setBackgroundColor(0.95, 0.95, 0.95)
  
  -- Initialize HTTPS module
  utils.logPerformance("Initializing HTTPS module")
  https.init()
  
  -- Load UI resources
  utils.logPerformance("Loading UI resources")
  ui.loadFonts()
  
  -- Initial data fetch
  utils.logPerformance("Starting initial data fetch")
  app.loadTopStories()
  
  -- Setup key information
  print("Press F5 to switch to mock data mode if experiencing connection issues")
  print("Press Ctrl+Down to load more stories")
  utils.logPerformance("App initialization complete")
end

-- Story loading
function app.loadTopStories(page)
  utils.logPerformance("Starting to load top stories (page " .. (page or "initial") .. ")")
  local state = app.state
  state.ui.loading = true
  state.ui.error = nil
  
  if page == 1 then
    state.ui.scrollY = 0  -- Reset scroll position for first page
  end
  
  state.ui.usingMockData = false
  
  api.fetchTopStories(function(success, result)
    utils.logPerformance("Received stories data - success: " .. tostring(success))
    state.ui.loading = false
    
    if success then
      utils.logPerformance("Processing " .. #result.items .. " stories")
      if page == 1 then
        state.stories = result.items
      else
        -- Append new stories
        for _, story in ipairs(result.items) do
          table.insert(state.stories, story)
        end
      end
      
      -- Update pagination
      state.pagination.currentPage = result.page
      state.pagination.totalPages = result.totalPages
      
      -- Track mock data usage
      state.ui.usingMockData = https.isUsingMockData()
      utils.logPerformance("Stories processed and ready to display")
    else
      app.handleError("Failed to load stories: " .. (result or "Unknown error"))
    end
  end, page or state.pagination.currentPage)
end

function app.loadNextPage()
  local state = app.state
  if state.pagination.currentPage < state.pagination.totalPages then
    app.loadTopStories(state.pagination.currentPage + 1)
  end
end

function app.loadStoryDetails(storyId)
  utils.logPerformance("Starting to load story details for ID: " .. storyId)
  local state = app.state
  state.ui.loading = true
  state.ui.error = nil
  state.ui.scrollY = 0
  
  api.fetchStoryDetails(storyId, function(success, result)
    utils.logPerformance("Received story details - success: " .. tostring(success))
    
    if success then
      state.selectedStory = result
      state.screen = "story_detail"
      
      -- Load comments
      utils.logPerformance("Proceeding to load comments")
      app.loadStoryComments(storyId)
    else
      state.ui.loading = false
      app.handleError("Failed to load story details: " .. (result or "Unknown error"))
    end
  end)
end

function app.loadStoryComments(storyId)
  utils.logPerformance("Starting to load comments for story ID: " .. storyId)
  local state = app.state
  state.comments = {}
  
  api.fetchStoryComments(storyId, function(success, result)
    utils.logPerformance("Received comments data - success: " .. tostring(success) .. ", count: " .. (success and #result or 0))
    state.ui.loading = false
    
    if success then
      state.comments = result
      utils.logPerformance("Comments processed and ready to display")
    else
      app.handleError("Failed to load comments: " .. (result or "Unknown error"))
    end
  end)
end

-- Error handling
function app.handleError(message)
  local state = app.state
  state.ui.error = message
  
  -- If using mock data, retry with it
  if https.isUsingMockData() then
    print("Retrying with mock data...")
    state.ui.error = nil
    state.ui.loading = true
    
    -- Small delay to make retry visible
    love.timer.sleep(0.5)
    
    -- Retry based on current screen
    if state.screen == "stories" then
      app.loadTopStories(1) -- Reset to first page for consistency
    elseif state.screen == "story_detail" and state.selectedStory then
      app.loadStoryComments(state.selectedStory.id)
    end
  else
    print(message)
    print("Press F5 to switch to mock data mode")
  end
end

-- LÖVE callbacks
function love.load()
  utils.logPerformance("LÖVE load callback started")
  app.init()
  utils.logPerformance("LÖVE load callback completed")
end

function love.update(dt)
  local state = app.state
  
  -- Process HTTP requests
  https.update(dt)
  
  -- Auto-refresh timer
  state.refreshTimer = state.refreshTimer + dt
  if state.refreshTimer >= state.autoRefreshInterval then
    state.refreshTimer = 0
    if state.screen == "stories" then
      app.loadTopStories(1) -- Refresh from first page
    end
  end
end

-- Add a helper function to control debug logging
local function shouldLogDebug(state)
  -- Only log if verbose logging is enabled AND we're at the logging interval
  return state.debug.enableVerboseLogging and state.debug.frameCounter == 0
end

function love.draw()
  local state = app.state
  local debug = state.debug
  debug.frameCounter = (debug.frameCounter + 1) % debug.logInterval
  
  -- Only log start of draw cycle if verbose logging is enabled and we're at the log interval
  if shouldLogDebug(state) then
    utils.logPerformance("Starting draw cycle")
  end
  
  -- Draw main content based on current screen
  local drawStart = love.timer.getTime()
  
  -- Draw UI based on current screen
  if state.screen == "stories" then
    -- Note: No logging here as we've moved all logging control to inside UI functions
    ui.drawStoryList(
      state.stories, 
      state.ui.scrollY, 
      state.ui.loading, 
      state.ui.error,
      state.pagination.currentPage, 
      state.pagination.totalPages
    )
  elseif state.screen == "story_detail" then
    -- Note: No logging here as we've moved all logging control to inside UI functions
    ui.drawStoryDetail(
      state.selectedStory, 
      state.comments, 
      state.ui.scrollY, 
      state.ui.loading, 
      state.ui.error
    )
  end
  
  local drawTime = love.timer.getTime() - drawStart
  -- Only log if drawing is significantly slow (more than 33ms, which is about 30fps)
  -- or if verbose logging is enabled on the log interval
  if drawTime > 0.033 or (debug.enableVerboseLogging and debug.frameCounter == 0) then
    utils.logPerformance("Content drawing took " .. string.format("%.3f", drawTime) .. "s")
  end
  
  -- Draw overlays
  if state.ui.loading then
    ui.drawLoadingIndicator()
  end
  
  if state.ui.error then
    ui.drawErrorMessage(state.ui.error)
  end
  
  -- Draw mock data indicator
  if state.ui.usingMockData then
    ui.drawMockDataIndicator()
  end
  
  -- Draw status bar at bottom of screen
  ui.drawStatusBar(state)
  
  -- Only log completion if we already logged the start
  if drawTime > 0.033 or (debug.enableVerboseLogging and debug.frameCounter == 0) then
    utils.logPerformance("Draw cycle completed in " .. string.format("%.3f", love.timer.getTime() - drawStart) .. "s")
  end
end

function love.mousepressed(x, y, button)
  if button ~= 1 then return end -- Only handle left clicks
  
  local state = app.state
  
  -- Handle clicks based on current screen
  if state.screen == "stories" then
    -- Story click
    local clickedIndex = ui.getStoryIndexAtPosition(y + state.ui.scrollY)
    if clickedIndex and state.stories[clickedIndex] then
      utils.logPerformance("Story clicked: index " .. clickedIndex .. ", id " .. state.stories[clickedIndex].id)
      app.loadStoryDetails(state.stories[clickedIndex].id)
      return
    end
    
    -- Refresh button
    if ui.isRefreshButtonClicked(x, y) then
      app.loadTopStories(1)
      return
    end
    
    -- Load more button
    if ui.isLoadMoreStoriesButtonClicked(x, y, state.ui.scrollY, #state.stories) then
      app.loadNextPage()
      return
    end
  elseif state.screen == "story_detail" then
    -- Back button
    if ui.isBackButtonClicked(x, y) then
      state.screen = "stories"
      state.ui.scrollY = 0
      return
    end
    
    -- Open URL button
    if state.selectedStory and ui.isOpenUrlButtonClicked(x, y) then
      if state.selectedStory.url then
        love.system.openURL(state.selectedStory.url)
      end
      return
    end
    
    -- Load more comments button
    if ui.isLoadMoreCommentsButtonClicked(x, y, #state.comments) then
      app.loadStoryComments(state.selectedStory.id)
      return
    end
  end
end

function love.wheelmoved(x, y)
  local state = app.state
  
  -- Calculate maximum scroll
  local maxScroll
  if state.screen == "stories" then
    maxScroll = ui.getMaxScrollForStories(state.stories)
  else
    maxScroll = ui.getMaxScrollForStoryDetail(state.selectedStory, state.comments)
  end
  
  -- Apply scroll with boundaries
  state.ui.scrollY = math.max(0, math.min(state.ui.scrollY - y * 30, maxScroll))
end

function love.keypressed(key)
  local state = app.state
  
  -- Navigation keys
  if key == "escape" and state.screen == "story_detail" then
    state.screen = "stories"
    state.ui.scrollY = 0
  elseif key == "r" and love.keyboard.isDown("lctrl") then
    -- Refresh current view
    if state.screen == "stories" then
      app.loadTopStories(1)
    elseif state.screen == "story_detail" and state.selectedStory then
      app.loadStoryComments(state.selectedStory.id)
    end
  elseif key == "down" and love.keyboard.isDown("lctrl") then
    -- Load next page
    if state.screen == "stories" then
      app.loadNextPage()
    end
  elseif key == "f5" then
    -- Switch to mock data
    https.useMockData()
    app.loadTopStories(1)
  end
end

-- Enhance the keyreleased function to provide feedback when toggling logging
function love.keyreleased(key)
  if key == "d" and love.keyboard.isDown("lctrl") then
    -- Toggle debug logging with Ctrl+D
    app.state.debug.enableVerboseLogging = not app.state.debug.enableVerboseLogging
    -- Make this feedback message more visible
    print("\n========================================")
    print("Verbose logging " .. (app.state.debug.enableVerboseLogging and "ENABLED" or "DISABLED"))
    print("========================================\n")
  end
end
