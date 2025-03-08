-- Hacker News Client for LÖVE2D
-- Main application file

-- Import modules
local api = require("api")
local ui = require("ui")
local utils = require("utils")
local https = require("https")

-- Application state
local state = {
    screen = "stories", -- "stories" or "story_detail"
    stories = {},
    selectedStory = nil,
    comments = {},
    loading = false,
    error = nil,
    scrollY = 0,
    refreshTimer = 0,
    autoRefreshInterval = 300, -- 5 minutes in seconds
    usingMockData = false  -- Track if we're using mock data
}

function love.load()
    -- Set window properties
    love.window.setTitle("Love2D Hacker News Client")
    love.window.setMode(800, 600, {resizable = true})
    love.graphics.setBackgroundColor(0.95, 0.95, 0.95)
    
    -- Initialize HTTPS module
    https.init()
    
    -- Add key handler for switching to mock mode
    print("Press F5 to switch to mock data mode if experiencing connection issues")
    
    -- Load font
    ui.loadFonts()
    
    -- Initial data fetch
    loadTopStories()
end

function loadTopStories()
    state.loading = true
    state.error = nil
    state.scrollY = 0
    state.usingMockData = false
    
    api.fetchTopStories(function(success, result)
        state.loading = false
        
        if success then
            state.stories = result
            -- Check if we're using mock data (for user feedback)
            state.usingMockData = https.isUsingMockData()
        else
            state.error = "Failed to load stories: " .. (result or "Unknown error")
            -- If we're in mock mode, we'll retry with mock data
            if https.isUsingMockData() then
                print("Retrying with mock data...")
                -- Clear the error message since we're retrying
                state.error = nil
                state.loading = true
                -- Add a small delay to make the retry visible
                love.timer.sleep(0.5)
                -- Retry fetch
                api.fetchTopStories(function(mockSuccess, mockResult)
                    state.loading = false
                    if mockSuccess then
                        state.stories = mockResult
                        state.usingMockData = true
                    else
                        state.error = "Failed to load stories: " .. (mockResult or "Unknown error")
                    end
                end)
            else
                print("Error loading stories: " .. (result or "Unknown error"))
                print("Press F5 to switch to mock data mode")
            end
        end
    end)
end

function loadStoryDetails(storyId)
    state.loading = true
    state.error = nil
    state.scrollY = 0
    
    api.fetchStoryDetails(storyId, function(success, result)
        if success then
            state.selectedStory = result
            state.screen = "story_detail"
            
            -- Load comments
            loadStoryComments(storyId)
        else
            state.error = "Failed to load story details: " .. (result or "Unknown error")
            state.loading = false
        end
    end)
end

function loadStoryComments(storyId)
    state.comments = {}
    
    api.fetchStoryComments(storyId, function(success, result)
        state.loading = false
        
        if success then
            state.comments = result
        else
            state.error = "Failed to load comments: " .. (result or "Unknown error")
        end
    end)
end

function love.update(dt)
    -- Update HTTPS module to process requests
    https.update(dt)  -- Add the dt parameter here
    
    -- Update refresh timer
    state.refreshTimer = state.refreshTimer + dt
    if state.refreshTimer >= state.autoRefreshInterval then
        state.refreshTimer = 0
        if state.screen == "stories" then
            loadTopStories()
        end
    end
end

function love.draw()
    if state.screen == "stories" then
        ui.drawStoryList(state.stories, state.scrollY, state.loading, state.error)
    elseif state.screen == "story_detail" then
        ui.drawStoryDetail(state.selectedStory, state.comments, state.scrollY, state.loading, state.error)
    end
    
    -- Draw loading indicator if needed
    if state.loading then
        ui.drawLoadingIndicator()
    end
    
    -- Draw error message if present
    if state.error then
        ui.drawErrorMessage(state.error)
    end
    
    -- Indicate when using mock data
    if state.usingMockData then
        love.graphics.setColor(0.9, 0.5, 0.1)
        love.graphics.setFont(ui.fonts.small)
        love.graphics.printf("Using mock data (press F5 to refresh)", 0, 5, love.graphics.getWidth(), "right")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        if state.screen == "stories" then
            -- Check if a story was clicked
            local clickedIndex = ui.getStoryIndexAtPosition(y + state.scrollY)
            if clickedIndex and state.stories[clickedIndex] then
                loadStoryDetails(state.stories[clickedIndex].id)
            end
            
            -- Check if refresh button was clicked
            if ui.isRefreshButtonClicked(x, y) then
                loadTopStories()
            end
        elseif state.screen == "story_detail" then
            -- Check if back button was clicked
            if ui.isBackButtonClicked(x, y) then
                state.screen = "stories"
                state.scrollY = 0
            end
            
            -- Check if open in browser button was clicked
            if state.selectedStory and ui.isOpenUrlButtonClicked(x, y) then
                if state.selectedStory.url then
                    love.system.openURL(state.selectedStory.url)
                end
            end
            
            -- Check if load more comments button was clicked
            if ui.isLoadMoreCommentsButtonClicked(x, y, #state.comments) then
                loadStoryComments(state.selectedStory.id)
            end
        end
    end
end

function love.wheelmoved(x, y)
    -- Scroll up/down
    local maxScroll
    if state.screen == "stories" then
        maxScroll = ui.getMaxScrollForStories(state.stories)
    else
        maxScroll = ui.getMaxScrollForStoryDetail(state.selectedStory, state.comments)
    end
    
    state.scrollY = math.max(0, math.min(state.scrollY - y * 30, maxScroll))
end

function love.keypressed(key)
    if key == "escape" and state.screen == "story_detail" then
        state.screen = "stories"
        state.scrollY = 0
    elseif key == "r" and love.keyboard.isDown("lctrl") then
        if state.screen == "stories" then
            loadTopStories()
        elseif state.screen == "story_detail" and state.selectedStory then
            loadStoryComments(state.selectedStory.id)
        end
    elseif key == "f5" then
        -- Switch to mock data mode
        https.useMockData()
        loadTopStories()
    end
end
