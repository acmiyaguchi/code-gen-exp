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
local https
local splash = require("splash") -- Load splash module at the beginning
local app = {}

-- Application state
app.state = {
  screen = "splash", -- "splash", "stories", or "story_detail"
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
  },
  splash = {
    startTime = 0,
    duration = 2.0,  -- Show splash for 2 seconds minimum
    minDuration = 2.0,
    complete = false,
    readyToTransition = false,
    pendingInitialization = true
  }
}

-- Initialize the application
function app.init()
  utils.logPerformance("Starting app initialization")
  
  -- Set window properties
  love.window.setTitle("Love2D Hacker News Client")
  love.window.setMode(800, 600, {resizable = true})
  
  -- Start with dark background for splash screen visibility
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
  
  -- Initialize splash screen early
  splash.init()
  
  -- Load UI resources
  utils.logPerformance("Loading UI resources")
  ui.loadFonts()
  
  -- Start splash screen timer
  app.state.splash.startTime = love.timer.getTime()
  app.state.screen = "splash" -- Ensure we start at splash screen
  
  utils.logPerformance("App initialization complete")
  
  -- We'll load HTTPS module and start network operations after a delay
  -- to ensure splash screen is visible first
  app.state.splash.pendingInitialization = true
end

-- Delayed initialization of network operations
function app.delayedInit()
  -- Import HTTPS module here to defer its initialization
  https = require("https")
  
  -- Initialize HTTPS module
  utils.logPerformance("Initializing HTTPS module (delayed)")
  https.init()
  
  -- Start loading data
  app.loadInitialData()
  
  app.state.splash.pendingInitialization = false
end

-- Load initial data in the background
function app.loadInitialData()
  utils.logPerformance("Starting initial data fetch")
  app.state.ui.loading = true
  
  -- Set readyToTransition when data is loaded but respect minimum splash duration
  app.loadTopStories(function()
    app.state.splash.readyToTransition = true
  end)
end

-- Exit splash screen and go to main app
function app.exitSplashScreen()
  -- Switch to light theme when exiting splash screen
  love.graphics.setBackgroundColor(0.95, 0.95, 0.95)
  
  app.state.screen = "stories"
  app.state.splash.complete = true
  utils.logPerformance("Exited splash screen")
end

-- LÖVE callbacks
function love.load()
  utils.logPerformance("LÖVE load callback started")
  app.init()
  utils.logPerformance("LÖVE load callback completed")
end

function love.update(dt)
  local state = app.state
  
  -- Check if we need to do delayed initialization
  -- Use a timer to ensure splash screen is visible for at least a frame
  if state.splash and state.splash.pendingInitialization then
    -- Add a small delay before starting HTTP operations
    if love.timer.getTime() - state.splash.startTime > 0.1 then
      app.delayedInit()
    end
  end
  
  -- Process HTTP requests if HTTPS module is loaded
  if https then
    https.update(dt)
  end
  
  if state.screen == "splash" then
    -- Calculate how long the splash has been shown
    local splashElapsedTime = love.timer.getTime() - state.splash.startTime
    
    -- Check if it's time to exit the splash screen
    if splashElapsedTime >= state.splash.minDuration and state.splash.readyToTransition then
      app.exitSplashScreen()
    end
    
    -- Force timeout if splash screen takes too long (10 seconds max)
    if splashElapsedTime > 10.0 then
      utils.logPerformance("Splash screen timeout - forcing transition")
      
      -- If no data was loaded, try with mock data
      if #app.state.stories == 0 then
        https.useMockData()
        app.loadTopStories()
      end
      
      app.exitSplashScreen()
    end
  else
    -- Update loading state based on active requests
    local requestStats = https.getRequestStats()
    if requestStats.active > 0 then
      state.ui.loading = true
    elseif state.ui.loading and requestStats.active == 0 then
      -- Only set loading to false if we're not in the middle of a multi-step operation
      -- This gives UI time to process received data
      if not state.ui.processingData then
        state.ui.loading = false
      end
    end
    
    -- Auto-refresh timer
    state.refreshTimer = state.refreshTimer + dt
    if state.refreshTimer >= state.autoRefreshInterval then
      state.refreshTimer = 0
      if state.screen == "stories" then
        app.loadTopStories()
      end
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
  
  if state.screen == "splash" then
    -- Draw splash screen (no need to require it here since we already did at the top)
    splash.draw()
    
    -- Add loading info on top of splash screen if needed
    if state.ui.loading and https then
      local requestStats = https.getRequestStats()
      if requestStats and requestStats.active > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        local loadingText = "Loading stories (" .. requestStats.active .. " requests active)"
        love.graphics.printf(loadingText, 0, love.graphics.getHeight() - 20, love.graphics.getWidth(), "center")
      end
    end
  elseif state.screen == "stories" then
    ui.drawStoryList(
      state.stories, 
      state.ui.scrollY, 
      state.ui.loading, 
      state.ui.error,
      state.pagination.currentPage, 
      state.pagination.totalPages
    )
  elseif state.screen == "story_detail" then
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

-- Story loading
function app.loadTopStories(callback)
  utils.logPerformance("Starting to load top stories")
  local state = app.state
  state.ui.loading = true
  state.ui.error = nil
  
  api.fetchTopStories(function(success, result)
    utils.logPerformance("Received stories data - success: " .. tostring(success))
    state.ui.loading = false
    
    if success then
      utils.logPerformance("Processing " .. #result.items .. " stories")
      state.stories = result.items
      state.pagination.currentPage = result.page
      state.pagination.totalPages = result.totalPages
      state.ui.usingMockData = https.isUsingMockData()
      utils.logPerformance("Stories processed and ready to display")
      if callback then callback() end
    else
      app.handleError("Failed to load stories: " .. (result or "Unknown error"))
    end
  end, 1)
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
      
      -- Load comments - state remains loading
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

-- Additional key handling for splash screen
function love.keypressed(key)
  local state = app.state
  
  -- Skip splash screen with any key press
  if state.screen == "splash" and key ~= nil then
    app.exitSplashScreen()
    return
  end
  
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
