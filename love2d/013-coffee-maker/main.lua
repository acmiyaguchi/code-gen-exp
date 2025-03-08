-- Coffee Maker Simulation
-- A simple interactive coffee maker using Love2D

-- Global variables
local timer = 0
local isBrewingCoffee = false
local fillLevel = 0
local maxFillLevel = 400
local drips = {}
local nextDripTime = 0
local resetButton = {x = 50, y = 500, width = 100, height = 40}

-- Colors
local colors = {
    background = {0.9, 0.9, 0.9},
    carafe = {0.8, 0.8, 0.8, 0.5},
    coffee = {0.4, 0.2, 0.1},
    machine = {0.6, 0.6, 0.6},
    drip = {0.25, 0.15, 0.05},
    button = {0.7, 0.3, 0.3},
    buttonHover = {0.8, 0.4, 0.4},
    text = {0.1, 0.1, 0.1}
}

-- Initialize the game
function love.load()
    love.window.setTitle("Coffee Maker Simulation")
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(colors.background)
    font = love.graphics.newFont(16)
    love.graphics.setFont(font)
    
    startBrewing()
end

-- Start the brewing process
function startBrewing()
    isBrewingCoffee = true
    timer = 0
    fillLevel = 0
    drips = {}
    nextDripTime = 0
end

-- Reset the coffee maker
function resetCoffeeMaker()
    startBrewing()
end

-- Check if a point is inside a rectangle
function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

-- Update the simulation
function love.update(dt)
    if isBrewingCoffee then
        timer = timer + dt
        
        -- Update fill level (slower at the beginning, faster in the middle, slower at the end)
        local fillRate = 8
        local normalizedFill = fillLevel / maxFillLevel
        local fillFactor = 1
        
        -- Simulate non-linear filling
        if normalizedFill < 0.2 then
            fillFactor = 0.7
        elseif normalizedFill > 0.8 then
            fillFactor = 0.5
        end
        
        fillLevel = math.min(fillLevel + (fillRate * dt * fillFactor), maxFillLevel)
        
        -- Generate coffee drips
        if timer > nextDripTime then
            local drip = {
                x = 400,
                y = 150,
                speed = love.math.random(80, 120),
                size = love.math.random(2, 4)
            }
            table.insert(drips, drip)
            nextDripTime = timer + love.math.random(0.1, 0.3)
        end
        
        -- Update drip positions
        for i = #drips, 1, -1 do
            local drip = drips[i]
            drip.y = drip.y + drip.speed * dt
            
            -- Remove drips that have reached the coffee level or gone too far
            local coffeeY = 500 - fillLevel
            if drip.y > coffeeY or drip.y > 500 then
                table.remove(drips, i)
            end
        end
        
        -- Stop brewing when full
        if fillLevel >= maxFillLevel then
            isBrewingCoffee = false
        end
    end
end

-- Handle mouse clicks
function love.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        if pointInRect(x, y, resetButton.x, resetButton.y, resetButton.width, resetButton.height) then
            resetCoffeeMaker()
        end
    end
end

-- Draw the simulation
function love.draw()
    -- Draw coffee machine body
    love.graphics.setColor(colors.machine)
    love.graphics.rectangle("fill", 300, 100, 200, 100)
    
    -- Draw drip mechanism
    love.graphics.rectangle("fill", 380, 200, 40, 20)
    
    -- Draw carafe
    love.graphics.setColor(colors.carafe)
    
    -- Carafe body
    love.graphics.polygon("fill", 
        350, 220,  -- Top left
        450, 220,  -- Top right
        470, 500,  -- Bottom right
        330, 500   -- Bottom left
    )
    
    -- Carafe handle
    love.graphics.polygon("fill",
        450, 300,
        480, 300,
        480, 400,
        470, 400
    )
    
    -- Draw coffee in carafe
    love.graphics.setColor(colors.coffee)
    local coffeeY = 500 - fillLevel
    love.graphics.polygon("fill",
        335, 500,
        465, 500,
        460, coffeeY + 10,
        340, coffeeY + 10
    )
    
    -- Draw drips
    love.graphics.setColor(colors.drip)
    for _, drip in ipairs(drips) do
        love.graphics.circle("fill", drip.x, drip.y, drip.size)
    end
    
    -- Draw reset button
    local mx, my = love.mouse.getPosition()
    if pointInRect(mx, my, resetButton.x, resetButton.y, resetButton.width, resetButton.height) then
        love.graphics.setColor(colors.buttonHover)
    else
        love.graphics.setColor(colors.button)
    end
    love.graphics.rectangle("fill", resetButton.x, resetButton.y, resetButton.width, resetButton.height)
    
    -- Draw button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Reset", resetButton.x, resetButton.y + 12, resetButton.width, "center")
    
    -- Draw timer and fill level
    love.graphics.setColor(colors.text)
    love.graphics.print("Time: " .. string.format("%.1f", timer) .. " seconds", 50, 50)
    love.graphics.print("Fill Level: " .. string.format("%.1f", (fillLevel / maxFillLevel) * 100) .. "%", 50, 80)
    
    -- Draw "brewing" or "ready" status
    if isBrewingCoffee then
        love.graphics.print("Status: Brewing...", 50, 110)
    else
        love.graphics.print("Status: Ready!", 50, 110)
    end
end
