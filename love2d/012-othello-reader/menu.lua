
local UI = require('ui')
local Menu = {}

local state
local expanded_acts = {}

function Menu.init(app_state)
    state = app_state
end

function Menu.update(dt)
    -- Nothing to update in menu mode
end

function Menu.draw()
    local width, height = love.graphics.getDimensions()
    
    -- Draw title
    love.graphics.setFont(UI.fonts.title)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Othello Interactive Reader", 0, 50, width, "center")
    
    -- Draw subheading
    love.graphics.setFont(UI.fonts.subtitle)
    love.graphics.printf("by William Shakespeare", 0, 120, width, "center")
    
    -- Draw menu instructions
    love.graphics.setFont(UI.fonts.normal)
    love.graphics.printf("Select an Act and Scene to begin reading:", 0, 200, width, "center")
    
    -- Draw Act and Scene menu
    local y_pos = 250
    local menu_width = width * 0.6
    local menu_x = (width - menu_width) / 2
    
    for act = 1, #state.play_data do
        -- Draw Act header
        local act_text = "Act " .. tostring(act)
        local act_box = {
            x = menu_x,
            y = y_pos,
            width = menu_width,
            height = 50
        }
        
        -- Draw Act box
        UI.draw_rounded_rect(act_box.x, act_box.y, act_box.width, act_box.height, 
            expanded_acts[act] and UI.colors.act_selected or UI.colors.act)
        
        -- Draw Act text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(UI.fonts.menu_act)
        love.graphics.printf(act_text, act_box.x, act_box.y + 10, act_box.width, "center")
        
        y_pos = y_pos + 60
        
        -- If this Act is expanded, show its Scenes
        if expanded_acts[act] then
            for scene = 1, #state.play_data[act] do
                local scene_text = "Scene " .. tostring(scene)
                local scene_box = {
                    x = menu_x + 40,
                    y = y_pos,
                    width = menu_width - 80,
                    height = 40
                }
                
                -- Draw Scene box
                UI.draw_rounded_rect(scene_box.x, scene_box.y, scene_box.width, scene_box.height, UI.colors.scene)
                
                -- Draw Scene text
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setFont(UI.fonts.menu_scene)
                love.graphics.printf(scene_text, scene_box.x, scene_box.y + 10, scene_box.width, "center")
                
                y_pos = y_pos + 50
            end
            y_pos = y_pos + 10  -- Extra spacing after scenes
        end
    end
    
    -- Draw credits at the bottom
    love.graphics.setFont(UI.fonts.small)
    love.graphics.printf("Text source: Project Gutenberg", 0, height - 40, width, "center")
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end  -- Only process left clicks
    
    local width = love.graphics.getWidth()
    local menu_width = width * 0.6
    local menu_x = (width - menu_width) / 2
    local y_pos = 250
    
    -- Check clicks on Acts
    for act = 1, #state.play_data do
        local act_box = {
            x = menu_x,
            y = y_pos,
            width = menu_width,
            height = 50
        }
        
        if UI.is_point_in_rect(x, y, act_box) then
            expanded_acts[act] = not expanded_acts[act]
            return
        end
        
        y_pos = y_pos + 60
        
        -- If this Act is expanded, check clicks on its Scenes
        if expanded_acts[act] then
            for scene = 1, #state.play_data[act] do
                local scene_box = {
                    x = menu_x + 40,
                    y = y_pos,
                    width = menu_width - 80,
                    height = 40
                }
                
                if UI.is_point_in_rect(x, y, scene_box) then
                    -- Navigate to the selected Act and Scene
                    state.current_act = act
                    state.current_scene = scene
                    state.mode = "reader"
                    return
                end
                
                y_pos = y_pos + 50
            end
            y_pos = y_pos + 10  -- Extra spacing after scenes
        end
    end
end

return Menu
