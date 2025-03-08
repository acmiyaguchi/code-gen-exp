--[[
  StarField module for LÖVE2D
  
  Creates and manages an infinite field of stars that adapts to viewport movement.
  Based on the StarField implementation from https://github.com/rfotino/space-ai/
]]

local StarField = {}
StarField.__index = StarField

-- Creates a new StarField
-- @param density Number of stars per pixel squared (default: 0.000125)
function StarField.new(density)
    local self = setmetatable({}, StarField)
    
    self.density = density or 0.000125
    self.bounds = {
        x = 0,
        y = 0,
        width = love.graphics.getWidth() / 2,
        height = love.graphics.getHeight() / 2
    }
    self.stars = {}
    self.color = {0.73, 0.73, 1.0} -- Light blue color (#bbf)
    self.starRadius = 2
    self.starOffset = 250
    
    -- Generate initial stars
    self:_addStars(self.bounds.x, self.bounds.y, self.bounds.width, self.bounds.height)
    
    return self
end

-- Generates stars in the given rectangle at the set density
-- @param x X coordinate of the rectangle
-- @param y Y coordinate of the rectangle
-- @param width Width of the rectangle
-- @param height Height of the rectangle
function StarField:_addStars(x, y, width, height)
    local numStars = math.floor(width * height * self.density)
    
    for i = 1, numStars do
        table.insert(self.stars, {
            x = x + (width * love.math.random()),
            y = y + (height * love.math.random())
        })
    end
end

-- Creates a deterministic random number generator based on a seed
-- @param seed The seed value
-- @return A function that returns a random number between 0 and 1
local function createRng(seed)
    return function()
        local x = math.sin(seed) * 10000
        seed = seed + 1
        return x - math.floor(x)
    end
end

-- Draws the starfield, covering the area visible in the viewport
-- @param viewport Table containing x, y, and scale properties
function StarField:draw(viewport)
    -- Get viewport dimensions
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local viewBounds = {
        x = viewport.x,
        y = viewport.y,
        width = screenWidth / viewport.scale,
        height = screenHeight / viewport.scale
    }
    
    local viewRight = viewBounds.x + viewBounds.width
    local viewBottom = viewBounds.y + viewBounds.height
    
    -- Calculate the grid of starfield cells we need to draw
    local minXIndex = math.floor((viewBounds.x - self.bounds.x - (self.starOffset / 2)) / self.bounds.width)
    local minYIndex = math.floor((viewBounds.y - self.bounds.y - (self.starOffset / 2)) / self.bounds.height)
    local minXCoord = self.bounds.x + (minXIndex * self.bounds.width)
    local minYCoord = self.bounds.y + (minYIndex * self.bounds.height)
    
    local maxXIndex = minXIndex +
        math.ceil((viewRight - minXCoord + (self.starOffset / 2)) / self.bounds.width)
    local maxYIndex = minYIndex +
        math.ceil((viewBottom - minYCoord + (self.starOffset / 2)) / self.bounds.height)
    
    -- Set star color
    love.graphics.setColor(self.color)
    
    -- Determine how to draw stars based on zoom level
    local effectiveRadius = self.starRadius * viewport.scale
    local drawAsRect = effectiveRadius < 1.5
    local starDiameter = 2 * self.starRadius
    
    -- Repeat the starfield to cover the entire viewport
    for i = minXIndex, maxXIndex do
        for j = minYIndex, maxYIndex do
            -- Use a deterministic RNG for this cell
            local rng = createRng(i + (j * 10000))
            
            for _, star in ipairs(self.stars) do
                -- Calculate the position of this star in this cell
                local adjX = star.x + self.bounds.x + (i * self.bounds.width) + 
                             ((rng() - 0.5) * self.starOffset)
                local adjY = star.y + self.bounds.y + (j * self.bounds.height) + 
                             ((rng() - 0.5) * self.starOffset)
                
                -- Check if star is in view before drawing
                if viewBounds.x <= adjX and adjX <= viewRight and
                   viewBounds.y <= adjY and adjY <= viewBottom then
                    
                    -- Convert world coordinates to screen coordinates
                    local screenX = (adjX - viewport.x) * viewport.scale
                    local screenY = (adjY - viewport.y) * viewport.scale
                    
                    if drawAsRect then
                        love.graphics.rectangle("fill", screenX, screenY, starDiameter * viewport.scale, starDiameter * viewport.scale)
                    else
                        love.graphics.circle("fill", screenX, screenY, effectiveRadius)
                    end
                end
            end
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return StarField
