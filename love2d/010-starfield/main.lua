-- Import the StarField module
local StarField = require('starfield')

-- Game state
local viewport = {
    x = 0,
    y = 0,
    scale = 1,
    speed = 200,
    zoomSpeed = 0.1  -- Controls how fast the zoom changes with mouse wheel
}

local starField

function love.load()
    -- Set up the window
    love.window.setTitle("Infinite Starfield")
    
    -- Create our starfield
    -- The density parameter controls how many stars appear (higher = more stars)
    starField = StarField.new(0.000125)
end

function love.update(dt)
    -- Handle movement with arrow keys
    if love.keyboard.isDown('left') then
        viewport.x = viewport.x - viewport.speed * dt
    end
    if love.keyboard.isDown('right') then
        viewport.x = viewport.x + viewport.speed * dt
    end
    if love.keyboard.isDown('up') then
        viewport.y = viewport.y - viewport.speed * dt
    end
    if love.keyboard.isDown('down') then
        viewport.y = viewport.y + viewport.speed * dt
    end
    
    -- Handle zoom with + and -
    if love.keyboard.isDown('=') then -- + key
        viewport.scale = viewport.scale * (1 + dt)
    end
    if love.keyboard.isDown('-') then
        viewport.scale = viewport.scale * (1 - dt)
    end
end

function love.draw()
    -- Black background
    love.graphics.setBackgroundColor(0, 0, 0)
    
    -- Draw the starfield with current viewport settings
    starField:draw(viewport)
    
    -- Display instructions
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print("Arrow keys: Move", 10, 10)
    love.graphics.print("+ / - or Mouse Wheel: Zoom", 10, 30)
    love.graphics.print("ESC: Quit", 10, 50)
end

-- Handle mouse wheel scrolling for zoom
function love.wheelmoved(x, y)
    if y > 0 then
        -- Zoom in
        viewport.scale = viewport.scale * (1 + viewport.zoomSpeed)
    elseif y < 0 then
        -- Zoom out
        viewport.scale = viewport.scale * (1 - viewport.zoomSpeed)
    end
    
    -- Prevent scale from becoming too small or too large
    viewport.scale = math.max(0.1, math.min(viewport.scale, 10))
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end
