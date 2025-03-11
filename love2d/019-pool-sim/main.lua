-- Import dependencies
local Game = require 'Game'

-- Global variables
local game

function love.load()
    love.physics.setMeter(100)  -- 100px = 1m
    game = Game:new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    game:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    game:mousemoved(x, y, dx, dy)
end

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
