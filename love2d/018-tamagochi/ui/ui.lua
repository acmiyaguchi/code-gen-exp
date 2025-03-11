local UI = {}
UI.__index = UI

function UI.new(pet)
    local self = setmetatable({}, UI)
    self.pet = pet
    
    -- Define buttons
    self.buttons = {
        { id = "feed", text = "Feed", x = 50, y = 400, width = 80, height = 30 },
        { id = "play", text = "Play", x = 150, y = 400, width = 80, height = 30 },
        { id = "clean", text = "Clean", x = 250, y = 400, width = 80, height = 30 },
        { id = "sleep", text = "Sleep", x = 350, y = 400, width = 80, height = 30 },
        { id = "medicine", text = "Medicine", x = 450, y = 400, width = 80, height = 30 }
    }
    
    return self
end

function UI:update(dt)
    -- Update any UI animations or elements
end

function UI:draw()
    -- Draw stat bars
    self:drawStatBars()
    
    -- Draw buttons
    for _, button in ipairs(self.buttons) do
        -- Button background
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
        -- Button border
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
        
        -- Button text
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(button.text, button.x, button.y + 8, button.width, "center")
    end
    
    -- Draw pet info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Name: " .. self.pet.name, 50, 50)
    love.graphics.print("Age: " .. math.floor(self.pet.age), 50, 70)
    
    -- Draw stage text
    local stageNames = {"Egg", "Baby", "Child", "Teen", "Adult", "Elder"}
    love.graphics.print("Stage: " .. stageNames[self.pet.stage], 50, 90)
    
    -- Draw status indicators
    if self.pet.isDead then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("DECEASED", 0, 200, love.graphics.getWidth(), "center")
    elseif self.pet.isSick then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.printf("SICK", 0, 200, love.graphics.getWidth(), "center")
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function UI:drawStatBars()
    local barWidth = 150
    local barHeight = 20
    local startX = 500
    local startY = 50
    local spacing = 30
    
    -- Health bar
    love.graphics.print("Health:", startX - 80, startY)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", startX, startY, barWidth, barHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", startX, startY, barWidth * (self.pet.health / 100), barHeight)
    
    -- Hunger bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Hunger:", startX - 80, startY + spacing)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", startX, startY + spacing, barWidth, barHeight)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("fill", startX, startY + spacing, barWidth * (self.pet.hunger / 100), barHeight)
    
    -- Happiness bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Happiness:", startX - 80, startY + spacing * 2)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", startX, startY + spacing * 2, barWidth, barHeight)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", startX, startY + spacing * 2, barWidth * (self.pet.happiness / 100), barHeight)
    
    -- Energy bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Energy:", startX - 80, startY + spacing * 3)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", startX, startY + spacing * 3, barWidth, barHeight)
    love.graphics.setColor(0, 0.7, 1)
    love.graphics.rectangle("fill", startX, startY + spacing * 3, barWidth * (self.pet.energy / 100), barHeight)
    
    -- Cleanliness bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Cleanliness:", startX - 80, startY + spacing * 4)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", startX, startY + spacing * 4, barWidth, barHeight)
    love.graphics.setColor(0.5, 0.8, 1)
    love.graphics.rectangle("fill", startX, startY + spacing * 4, barWidth * (self.pet.cleanliness / 100), barHeight)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function UI:handleClick(x, y)
    for _, button in ipairs(self.buttons) do
        if x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            return button.id
        end
    end
    return nil
end

return UI
