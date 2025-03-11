-- main.lua
-- Entry point for the LÖVE2D pool physics demo

-- Import dependencies
local Game = require 'Game'

-- Global variables
local game

--[[
    Initializes the game
]]
function love.load()
    love.physics.setMeter(100)  -- 100px = 1m
    game = Game:new()
end

--[[
    Updates game state
]]
function love.update(dt)
    game:update(dt)
end

--[[
    Renders the game
]]
function love.draw()
    game:draw()
end

--[[
    Mouse press callback
]]
function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end

--[[
    Mouse release callback
]]
function love.mousereleased(x, y, button)
    game:mousereleased(x, y, button)
end

--[[
    Mouse movement callback
]]
function love.mousemoved(x, y, dx, dy)
    game:mousemoved(x, y, dx, dy)
end

--[[
    Keyboard press callback
    
    Special keys:
    - r: Reset the game
    - escape: Quit the game
    - d: Toggle debug visualization
]]
function love.keypressed(key)
    if key == "r" then
        game:reset()
    elseif key == "escape" then
        love.event.quit()
    elseif key == "d" then
        game:toggleDebug()
    else
        game:keypressed(key)
    end
end
