-- UI rendering and interaction

local ui = {}
local utils = require("utils")

-- UI constants
local PADDING = 10
local STORY_HEIGHT = 80
local COMMENT_PADDING = 15
local MAX_VISIBLE_COMMENTS = 10

-- Fonts
local fonts = {
    title = nil,
    subtitle = nil,
    normal = nil,
    small = nil,
    button = nil
}

-- Colors
local colors = {
    background = {0.95, 0.95, 0.95},
    storyBg = {1, 1, 1},
    storyTitle = {0.1, 0.1, 0.1},
    storyMeta = {0.5, 0.5, 0.5},
    divider = {0.8, 0.8, 0.8},
    button = {1, 0.5, 0},
    buttonHover = {1, 0.7, 0.3},
    buttonText = {1, 1, 1},
    error = {0.8, 0.2, 0.2},
    loading = {0.2, 0.6, 0.8}
}

-- Load fonts
function ui.loadFonts()
    fonts.title = love.graphics.newFont(18)
    fonts.subtitle = love.graphics.newFont(14)
    fonts.normal = love.graphics.newFont(12)
    fonts.small = love.graphics.newFont(10)
    fonts.button = love.graphics.newFont(14)
end

-- Draw the story list screen
function ui.drawStoryList(stories, scrollY, loading, error)
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Draw header
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, windowWidth, 50)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    love.graphics.print("Hacker News", PADDING, 15)
    
    -- Draw refresh button
    ui.drawButton("Refresh", windowWidth - 100, 10, 80, 30)
    
    -- Draw stories
    if #stories > 0 then
        love.graphics.translate(0, -scrollY)
        
        for i, story in ipairs(stories) do
            local y = 60 + (i-1) * STORY_HEIGHT
            
            -- Skip if not visible
            if y + STORY_HEIGHT > scrollY and y < scrollY + windowHeight then
                -- Story background
                love.graphics.setColor(colors.storyBg)
                love.graphics.rectangle("fill", PADDING, y, windowWidth - PADDING * 2, STORY_HEIGHT - PADDING)
                
                -- Story title
                love.graphics.setColor(colors.storyTitle)
                love.graphics.setFont(fonts.subtitle)
                love.graphics.printf(story.title or "No title", PADDING * 2, y + 10, windowWidth - PADDING * 4, "left")
                
                -- Story metadata
                love.graphics.setColor(colors.storyMeta)
                love.graphics.setFont(fonts.normal)
                
                local metaText = (story.score or 0) .. " points by " .. (story.by or "anonymous") 
                    .. " • " .. utils.timeAgo(story.time)
                
                love.graphics.print(metaText, PADDING * 2, y + 35)
                
                -- Comments count
                local commentCount = 0
                if story.kids then
                    commentCount = #story.kids
                end
                love.graphics.print(commentCount .. " comments", PADDING * 2, y + 55)
                
                -- Divider
                love.graphics.setColor(colors.divider)
                love.graphics.rectangle("fill", PADDING, y + STORY_HEIGHT - 1, windowWidth - PADDING * 2, 1)
            end
        end
        
        love.graphics.translate(0, scrollY)
    elseif not loading and not error then
        love.graphics.setColor(colors.storyMeta)
        love.graphics.setFont(fonts.normal)
        love.graphics.printf("No stories found", 0, 100, windowWidth, "center")
    end
end

-- Draw a story detail view
function ui.drawStoryDetail(story, comments, scrollY, loading, error)
    if not story then return end
    
    local windowWidth, windowHeight = love.graphics.getDimensions()
    
    -- Draw header
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, windowWidth, 50)
    
    -- Draw back button
    ui.drawButton("< Back", 10, 10, 80, 30)
    
    -- Story content (apply scroll)
    love.graphics.translate(0, -scrollY)
    
    -- Story title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    love.graphics.printf(story.title or "No title", PADDING, 60, windowWidth - PADDING * 2, "left")
    
    -- Story metadata
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(fonts.normal)
    
    local metaText = (story.score or 0) .. " points by " .. (story.by or "anonymous") 
        .. " • " .. utils.timeAgo(story.time)
    
    love.graphics.print(metaText, PADDING, 90)
    
    -- URL (if available)
    local urlY = 120
    if story.url then
        love.graphics.setColor(0.4, 0.6, 0.8)
        love.graphics.printf(utils.getHostname(story.url), PADDING, urlY, windowWidth - PADDING * 2, "left")
        
        -- Open URL button
        love.graphics.setColor(colors.button)
        ui.drawButton("Open in Browser", PADDING, urlY + 25, 150, 30)
        urlY = urlY + 70
    end
    
    -- Comments section
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.subtitle)
    love.graphics.print("Comments", PADDING, urlY)
    
    -- Draw comments
    local commentY = urlY + 40
    
    if #comments == 0 and not loading then
        love.graphics.setColor(colors.storyMeta)
        love.graphics.setFont(fonts.normal)
        love.graphics.print("No comments yet", PADDING, commentY)
    else
        for i, comment in ipairs(comments) do
            -- Skip if comment is deleted or dead
            if not comment.deleted and not comment.dead then
                -- Comment container
                love.graphics.setColor(colors.storyBg)
                local commentHeight = ui.calculateCommentHeight(comment, windowWidth - PADDING * 4)
                love.graphics.rectangle("fill", PADDING, commentY, windowWidth - PADDING * 2, commentHeight)
                
                -- Comment author and time
                love.graphics.setColor(colors.button)
                love.graphics.setFont(fonts.normal)
                love.graphics.print(
                    (comment.by or "anonymous") .. " • " .. utils.timeAgo(comment.time),
                    PADDING * 2, 
                    commentY + 10
                )
                
                -- Comment text
                love.graphics.setColor(colors.storyTitle)
                love.graphics.setFont(fonts.normal)
                local formattedText = utils.formatCommentText(comment.text or "")
                love.graphics.printf(
                    formattedText,
                    PADDING * 2,
                    commentY + 30,
                    windowWidth - PADDING * 4,
                    "left"
                )
                
                commentY = commentY + commentHeight + 10
            end
        end
        
        -- Load more comments button (if story has more comments)
        if story.kids and #story.kids > #comments then
            ui.drawButton(
                "Load More Comments", 
                windowWidth / 2 - 80, 
                commentY + 10, 
                160, 
                40
            )
            commentY = commentY + 60
        end
    end
    
    -- Reset translation
    love.graphics.translate(0, scrollY)
end

-- Calculate the height needed to display a comment
function ui.calculateCommentHeight(comment, maxWidth)
    if not comment or not comment.text then
        return 60 -- Minimum height
    end
    
    local text = utils.formatCommentText(comment.text)
    local font = fonts.normal
    
    local _, textLines = font:getWrap(text, maxWidth)
    return 40 + #textLines * font:getHeight()
end

-- Draw a button
function ui.drawButton(text, x, y, width, height)
    -- Button background
    love.graphics.setColor(colors.button)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Button text
    love.graphics.setColor(colors.buttonText)
    love.graphics.setFont(fonts.button)
    
    local textWidth = fonts.button:getWidth(text)
    local textHeight = fonts.button:getHeight()
    love.graphics.print(
        text, 
        x + (width - textWidth) / 2, 
        y + (height - textHeight) / 2
    )
end

-- Draw loading indicator
function ui.drawLoadingIndicator()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    love.graphics.setColor(colors.loading)
    love.graphics.setFont(fonts.subtitle)
    love.graphics.printf("Loading...", 0, windowHeight - 40, windowWidth, "center")
end

-- Draw error message
function ui.drawErrorMessage(message)
    local windowWidth, windowHeight = love.graphics.getDimensions()
    love.graphics.setColor(colors.error)
    love.graphics.rectangle("fill", 0, windowHeight - 50, windowWidth, 50)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.normal)
    love.graphics.printf(message, PADDING, windowHeight - 35, windowWidth - PADDING * 2, "center")
end

-- Check if a story index was clicked
function ui.getStoryIndexAtPosition(y)
    local index = math.floor((y - 60) / STORY_HEIGHT) + 1
    if index > 0 then
        return index
    end
    return nil
end

-- Check if refresh button was clicked
function ui.isRefreshButtonClicked(x, y)
    local windowWidth, _ = love.graphics.getDimensions()
    return x >= windowWidth - 100 and x <= windowWidth - 20 and y >= 10 and y <= 40
end

-- Check if back button was clicked
function ui.isBackButtonClicked(x, y)
    return x >= 10 and x <= 90 and y >= 10 and y <= 40
end

-- Check if open URL button was clicked
function ui.isOpenUrlButtonClicked(x, y)
    return x >= PADDING and x <= PADDING + 150 and y >= 145 and y <= 175
end

-- Check if load more comments button was clicked
function ui.isLoadMoreCommentsButtonClicked(x, y, commentCount)
    local windowWidth, _ = love.graphics.getDimensions()
    local btnX = windowWidth / 2 - 80
    local btnY = 120 + 70 + 40 + commentCount * 120 + 10
    
    return x >= btnX and x <= btnX + 160 and y >= btnY and y <= btnY + 40
end

-- Get maximum scroll amount for stories list
function ui.getMaxScrollForStories(stories)
    return 60 + #stories * STORY_HEIGHT - love.graphics.getHeight() + 20
end

-- Get maximum scroll amount for story detail
function ui.getMaxScrollForStoryDetail(story, comments)
    local commentHeight = 0
    for _, comment in ipairs(comments) do
        commentHeight = commentHeight + ui.calculateCommentHeight(comment, love.graphics.getWidth() - PADDING * 4) + 10
    end
    
    return 120 + commentHeight - love.graphics.getHeight() + 100
end

return ui
