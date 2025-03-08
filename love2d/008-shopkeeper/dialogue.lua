local DialogueSystem = {}
DialogueSystem.__index = DialogueSystem

function DialogueSystem.new()
    local self = setmetatable({}, DialogueSystem)
    self.dialogue = {}
    self.currentIndex = 1
    self.finished = true
    self.nextAction = nil
    self.selectedOption = 1
    return self
end

function DialogueSystem:startDialogue(dialogue)
    self.dialogue = dialogue
    self.currentIndex = 1
    self.finished = false
    self.nextAction = nil
    self.selectedOption = 1
end

function DialogueSystem:update(dt)
    -- Animation updates or timers could go here
end

function DialogueSystem:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local boxHeight = 150
    
    -- Draw dialogue box
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 20, windowHeight - boxHeight - 20, windowWidth - 40, boxHeight)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 20, windowHeight - boxHeight - 20, windowWidth - 40, boxHeight)
    
    -- Check if dialogue is nil or empty
    if not self.dialogue or #self.dialogue == 0 then return end
    
    -- Check if current index is valid
    if not self.currentIndex or self.currentIndex > #self.dialogue then
        self.currentIndex = 1
    end
    
    local currentDialogue = self.dialogue[self.currentIndex]
    if not currentDialogue then return end
    
    -- Draw speaker name
    if currentDialogue.speaker then
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.print(currentDialogue.speaker .. ":", 40, windowHeight - boxHeight - 10)
    end
    
    -- Draw dialogue text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(currentDialogue.text, 40, windowHeight - boxHeight + 20, windowWidth - 80, "left")
    
    -- Draw options if available
    if currentDialogue.options then
        for i, option in ipairs(currentDialogue.options) do
            if i == self.selectedOption then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(0.7, 0.7, 0.7)
            end
            
            love.graphics.print("> " .. option.text, 60, windowHeight - boxHeight + 50 + (i-1) * 25)
        end
    else
        love.graphics.setColor(0.7, 0.7, 1)
        love.graphics.print("Press SPACE to continue...", windowWidth - 220, windowHeight - 50)
    end
end

function DialogueSystem:handleInput(key)
    local currentDialogue = self.dialogue[self.currentIndex]
    if not currentDialogue then
        self.finished = true
        return
    end
    
    if currentDialogue.options then
        -- Handle option selection
        if key == "up" then
            self.selectedOption = math.max(1, self.selectedOption - 1)
        elseif key == "down" then
            self.selectedOption = math.min(#currentDialogue.options, self.selectedOption + 1)
        elseif key == "space" or key == "return" then
            local selectedOption = currentDialogue.options[self.selectedOption]
            
            if selectedOption.nextState == "exit" then
                self.finished = true
            elseif type(selectedOption.nextState) == "number" then
                self.currentIndex = selectedOption.nextState
            else
                self.finished = true
            end
            
            if selectedOption.action then
                self.nextAction = selectedOption.action
            end
        end
    else
        -- Handle regular dialogue progression
        if key == "space" or key == "return" then
            self.currentIndex = self.currentIndex + 1
            
            if self.currentIndex > #self.dialogue then
                self.finished = true
            end
        end
    end
end

function DialogueSystem:handleMouseClick(x, y, button)
    -- Implement mouse selection of dialogue options
    if button == 1 then -- Left click
        local windowHeight = love.graphics.getHeight()
        local boxHeight = 150
        
        local currentDialogue = self.dialogue[self.currentIndex]
        if currentDialogue and currentDialogue.options then
            for i, option in ipairs(currentDialogue.options) do
                local optionY = windowHeight - boxHeight + 50 + (i-1) * 25
                
                if y >= optionY and y <= optionY + 20 then
                    self.selectedOption = i
                    self:handleInput("return")
                    return
                end
            end
        else
            self:handleInput("space")
        end
    end
end

return DialogueSystem
