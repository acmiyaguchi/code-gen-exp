local GameState = require('states/gameState')
local TitleState = require('states/titleState')

-- Global game state
local currentState

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- For pixel art style
    math.randomseed(os.time())
    
    -- Initialize the game
    currentState = TitleState.new()
end

function love.update(dt)
    -- Update current state
    currentState:update(dt)
    
    -- Check for state changes
    if currentState.nextState then
        currentState = currentState.nextState
        currentState.nextState = nil
    end
end

function love.draw()
    currentState:draw()
end

function love.keypressed(key)
    currentState:keypressed(key)
    
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    currentState:mousepressed(x, y, button)
end
