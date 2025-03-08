-- Configuration settings
local settings = {
    windowTitle = "Severance Numbers",
    windowWidth = 800,
    windowHeight = 600,
    numNumbers = 100,
    numberRange = {1, 100},
    fontSize = 20,
    columns = 10,
    rows = 10,
    colSpacing = 80,
    rowSpacing = 60,
    hoverRadius = 120,       -- Radius of the circle of influence.  Directly controls size.
    maxScale = 3,          -- Maximum scale at the center of the circle
    minScale = 1,         -- NEW: Minimum scale at the edge of the circle (prevents disappearing)
    fontColor = {1, 1, 1},
    backgroundColor = {0, 0, 0}
}

-- Table to store the random numbers and their positions.
local numbers = {}

-- Mouse position.
local mouseX, mouseY = 0, 0

-- Function to calculate grid position (remains the same).
local function getNumberPosition(index)
    local x = (index - 1) % settings.columns * settings.colSpacing + settings.colSpacing / 2
    local y = math.floor((index - 1) / settings.columns) * settings.rowSpacing + settings.rowSpacing / 2
    return x, y
end

-- Function to generate the random numbers.
local function generateNumbers()
    numbers = {}
    for i = 1, settings.numNumbers do
        local x, y = getNumberPosition(i)
        table.insert(numbers, {
            value = math.random(settings.numberRange[1], settings.numberRange[2]),
            x = x,
            y = y,
            -- No longer store scale here.
            index = i
        })
    end
end

-- Linear scaling function.  This is the core change.
local function calculateLinearScale(distance, hoverRadius, maxScale, minScale)
    if distance > hoverRadius then
        return minScale
    end
    -- Linear interpolation between maxScale and minScale
    local scale = maxScale - (distance / hoverRadius) * (maxScale - minScale)
    return math.max(minScale, scale)  -- Ensure scale doesn't go below minScale
end

-- Function to draw a single number (now takes scale as an argument).
local function drawNumber(numberData, scale)
    local scaledFont = love.graphics.newFont(settings.fontSize * scale)
    love.graphics.setFont(scaledFont)
    local textWidth = scaledFont:getWidth(tostring(numberData.value))
    local textHeight = scaledFont:getHeight()
    love.graphics.setColor(unpack(settings.fontColor))
    love.graphics.print(numberData.value, numberData.x - textWidth / 2, numberData.y - textHeight / 2)
end

-- love.load (no changes).
function love.load()
    love.window.setTitle(settings.windowTitle)
    love.window.setMode(settings.windowWidth, settings.windowHeight)
    math.randomseed(os.time())
    generateNumbers()
end

-- love.update (simplified).
function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()
end

-- love.draw (now calculates scale directly).
function love.draw()
    love.graphics.setBackgroundColor(unpack(settings.backgroundColor))
    love.graphics.setColor(unpack(settings.fontColor))

    for i, numberData in ipairs(numbers) do
        local distance = math.sqrt((mouseX - numberData.x)^2 + (mouseY - numberData.y)^2)

        -- Calculate scale directly based on distance and hoverRadius.
        local scale = calculateLinearScale(distance, settings.hoverRadius, settings.maxScale, settings.minScale)

        drawNumber(numberData, scale)
    end
    --  For debugging, draw the circle of influence (optional)
    love.graphics.setColor(1, 0, 0, 0.2) -- Red, semi-transparent
    love.graphics.circle("line", mouseX, mouseY, settings.hoverRadius)
end

-- love.mousemoved (no longer needed).
function love.mousemoved(x, y, dx, dy, istouch)
    -- Mouse position is updated in love.update
end

-- Key press handler (remains the same).
function love.keypressed(key)
    if key == "r" then
        generateNumbers()
    end
end