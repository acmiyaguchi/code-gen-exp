
local UI = require('ui')
local Parser = require('parser')

local Reader = {}

local state
local scroll_offset = 0
local bubbles = {}
local max_scroll = 0

function Reader.init(app_state)
    state = app_state
end

function Reader.update(dt)
    -- Check if we need to update bubbles (if act or scene changed)
    local content_key = state.current_act .. "-" .. state.current_scene
    if not Reader.current_content_key or Reader.current_content_key ~= content_key then
        Reader.load_current_scene()
    end
end

function Reader.load_current_scene()
    -- Reset scroll position
    scroll_offset = 0
    
    -- Get the scene text
    local scene_text = state.play_data[state.current_act][state.current_scene]
    
    -- Process into bubbles
    bubbles = Parser.process_scene_into_bubbles(scene_text)
    
    -- Set current content key for cache checking
    Reader.current_content_key = state.current_act .. "-" .. state.current_scene
    
    -- Calculate max scroll based on content
    max_scroll = Reader.calculate_max_scroll()
end

function Reader.calculate_max_scroll()
    local height = love.graphics.getHeight()
    local total_height = UI.NAV_HEIGHT + 20  -- Start below nav bar
    
    for i, bubble_text in ipairs(bubbles) do
        local bubble_height = UI.calculate_text_height(bubble_text, UI.fonts.normal, 
                                                     UI.BUBBLE_WIDTH - UI.BUBBLE_PADDING * 2) 
                                                     + UI.BUBBLE_PADDING * 2 + 20
        total_height = total_height + bubble_height
    end
    
    return math.max(0, total_height - height)
end

function Reader.draw()
    local width, height = love.graphics.getDimensions()
    
    -- Draw navigation bar
    UI.draw_rounded_rect(0, 0, width, UI.NAV_HEIGHT, UI.colors.nav_bar)
    
    -- Draw navigation buttons
    local button_width = 100
    local button_height = 36
    local button_y = (UI.NAV_HEIGHT - button_height) / 2
    
    -- Previous Scene button
    UI.draw_rounded_rect(10, button_y, button_width, button_height, UI.colors.button)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(UI.fonts.button)
    love.graphics.printf("<<", 10, button_y + 8, button_width, "center")
    
    -- Next Scene button
    UI.draw_rounded_rect(width - button_width - 10, button_y, button_width, button_height, UI.colors.button)
    love.graphics.printf(">>", width - button_width - 10, button_y + 8, button_width, "center")
    
    -- Menu button
    local menu_button_width = 80
    UI.draw_rounded_rect(width / 2 - menu_button_width / 2, button_y, menu_button_width, button_height, UI.colors.button)
    love.graphics.printf("Menu", width / 2 - menu_button_width / 2, button_y + 8, menu_button_width, "center")
    
    -- Current location text
    love.graphics.setFont(UI.fonts.normal)
    love.graphics.printf(
        "Act " .. state.current_act .. ", Scene " .. state.current_scene,
        button_width + 20, button_y + 8, width - (button_width * 2) - 40, "center"
    )
    
    -- Draw text bubbles
    local y_pos = UI.NAV_HEIGHT + 20 - scroll_offset
    for i, bubble_text in ipairs(bubbles) do
        local bubble_height = UI.calculate_text_height(bubble_text, UI.fonts.normal, 
                                                     UI.BUBBLE_WIDTH - UI.BUBBLE_PADDING * 2) 
                                                     + UI.BUBBLE_PADDING * 2
                                                     
        -- Only draw bubbles that are visible on screen
        if y_pos + bubble_height > 0 and y_pos < height then
            UI.draw_rounded_rect((width - UI.BUBBLE_WIDTH) / 2, y_pos, 
                              UI.BUBBLE_WIDTH, bubble_height, UI.colors.bubble)
            
            love.graphics.setColor(UI.colors.text)
            love.graphics.setFont(UI.fonts.normal)
            love.graphics.printf(
                bubble_text,
                (width - UI.BUBBLE_WIDTH) / 2 + UI.BUBBLE_PADDING,
                y_pos + UI.BUBBLE_PADDING,
                UI.BUBBLE_WIDTH - UI.BUBBLE_PADDING * 2,
                "left"
            )
        end
        
        y_pos = y_pos + bubble_height + 20  -- Add spacing between bubbles
    end
end

function Reader.mousepressed(x, y, button)
    if button ~= 1 then return end  -- Only process left clicks
    
    local width = love.graphics.getWidth()
    local button_width = 100
    local button_height = 36
    local button_y = (UI.NAV_HEIGHT - button_height) / 2
    
    -- Check Previous Scene button
    if UI.is_point_in_rect(x, y, {x = 10, y = button_y, width = button_width, height = button_height}) then
        Reader.go_to_previous_scene()
        return
    end
    
    -- Check Next Scene button
    if UI.is_point_in_rect(x, y, {x = width - button_width - 10, y = button_y, width = button_width, height = button_height}) then
        Reader.go_to_next_scene()
        return
    end
    
    -- Check Menu button
    local menu_button_width = 80
    if UI.is_point_in_rect(x, y, {x = width / 2 - menu_button_width / 2, y = button_y, width = menu_button_width, height = button_height}) then
        state.mode = "menu"
        return
    end
end

function Reader.wheelmoved(x, y)
    -- Scroll up or down
    scroll_offset = scroll_offset - y * 60
    
    -- Clamp scroll_offset between 0 and max_scroll
    scroll_offset = math.max(0, math.min(scroll_offset, max_scroll))
end

function Reader.keypressed(key)
    if key == "up" then
        scroll_offset = math.max(0, scroll_offset - 60)
    elseif key == "down" then
        scroll_offset = math.min(max_scroll, scroll_offset + 60)
    elseif key == "pageup" then
        scroll_offset = math.max(0, scroll_offset - love.graphics.getHeight() / 2)
    elseif key == "pagedown" then
        scroll_offset = math.min(max_scroll, scroll_offset + love.graphics.getHeight() / 2)
    elseif key == "home" then
        scroll_offset = 0
    elseif key == "end" then
        scroll_offset = max_scroll
    elseif key == "left" then
        Reader.go_to_previous_scene()
    elseif key == "right" then
        Reader.go_to_next_scene()
    elseif key == "escape" then
        state.mode = "menu"
    end
end

function Reader.go_to_previous_scene()
    local scene = state.current_scene - 1
    local act = state.current_act
    
    if scene < 1 then
        act = act - 1
        if act < 1 then
            act = #state.play_data  -- Wrap to last act
        end
        scene = #state.play_data[act]  -- Get last scene of previous act
    end
    
    state.current_act = act
    state.current_scene = scene
    Reader.load_current_scene()
end

function Reader.go_to_next_scene()
    local scene = state.current_scene + 1
    local act = state.current_act
    
    if scene > #state.play_data[act] then
        act = act + 1
        if act > #state.play_data then
            act = 1  -- Wrap to first act
        end
        scene = 1  -- First scene of next act
    end
    
    state.current_act = act
    state.current_scene = scene
    Reader.load_current_scene()
end

return Reader
