local GameState = require('states/gameState')
local SaveSystem = require('utils/saveSystem')

local TitleState = {}
TitleState.__index = TitleState

function TitleState.new()
    local self = setmetatable({}, TitleState)
    
    self.title = "Tamagochi"
    self.options = {
        {text = "New Game", action = "new"},
        {text = "Continue", action = "continue"},
        {text = "Options", action = "options"}
    }
    self.selectedOption = 1
    
    -- Check if save exists
    self.hasSave = SaveSystem.hasSave()
    
    return self
end

function TitleState:update(dt)
    -- Any animations or effects for title screen
end

function TitleState:draw()
    -- Background
    love.graphics.setColor(0.2, 0.4, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    
    -- Title
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf(self.title, 0, 100, love.graphics.getWidth(), "center")
    
    -- Menu options
    love.graphics.setFont(love.graphics.newFont(24))
    local startY = 250
    
    for i, option in ipairs(self.options) do
        if i == 2 and not self.hasSave then -- 'Continue' option
            love.graphics.setColor(0.5, 0.5, 0.5) -- Grayed out
        elseif i == self.selectedOption then
            love.graphics.setColor(1, 1, 0) -- Selected color
        else
            love.graphics.setColor(1, 1, 1) -- Normal color
        end
        
        love.graphics.printf(option.text, 0, startY + (i-1) * 40, love.graphics.getWidth(), "center")
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function TitleState:keypressed(key)
    if key == "up" then
        self.selectedOption = math.max(1, self.selectedOption - 1)
    elseif key == "down" then
        self.selectedOption = math.min(#self.options, self.selectedOption + 1)
    elseif key == "return" or key == "space" then
        self:selectOption(self.options[self.selectedOption].action)
    end
end

function TitleState:mousepressed(x, y, button)
    if button ~= 1 then return end
    
    local startY = 250
    for i, option in ipairs(self.options) do
        -- Simple hit detection
        if y >= startY + (i-1) * 40 and y <= startY + i * 40 and
           x >= love.graphics.getWidth() / 2 - 100 and x <= love.graphics.getWidth() / 2 + 100 then
            
            if option.action == "continue" and not self.hasSave then
                -- Do nothing if trying to continue without a save
                return
            end
            
            self:selectOption(option.action)
            return
        end
    end
end

function TitleState:selectOption(action)
    if action == "new" then
        self.nextState = GameState.new()
    elseif action == "continue" and self.hasSave then
        local saveData = SaveSystem.load()
        self.nextState = GameState.new(saveData)
    elseif action == "options" then
        -- TODO: Create an OptionsState
    end
end

return TitleState
