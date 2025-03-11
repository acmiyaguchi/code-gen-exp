local Pet = require('pet')
local UI = require('ui/ui')
local SaveSystem = require('utils/saveSystem')

local GameState = {}
GameState.__index = GameState

function GameState.new(petData)
    local self = setmetatable({}, GameState)
    
    -- Create pet or load from save data
    if petData then
        self.pet = Pet.loadFromData(petData)
    else
        self.pet = Pet.new()
    end
    
    -- Game time
    self.totalTime = 0
    self.isDaytime = true
    self.dayLength = 120 -- seconds in a day cycle
    
    -- UI elements
    self.ui = UI.new(self.pet)
    
    return self
end

function GameState:update(dt)
    -- Update time cycle
    self.totalTime = self.totalTime + dt
    self.isDaytime = (self.totalTime % self.dayLength) < (self.dayLength / 2)
    
    -- Update pet
    self.pet:update(dt)
    
    -- Update UI
    self.ui:update(dt)
    
    -- Auto save every minute
    if math.floor(self.totalTime) % 60 == 0 then
        SaveSystem.save(self.pet:getSaveData())
    end
end

function GameState:draw()
    -- Background based on time of day
    if self.isDaytime then
        love.graphics.setColor(0.8, 0.9, 1)
    else
        love.graphics.setColor(0.1, 0.1, 0.3)
    end
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    
    -- Draw pet in the center
    self.pet:draw(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 50)
    
    -- Draw UI elements
    self.ui:draw()
end

function GameState:keypressed(key)
    -- Handle key inputs
    if key == "f" then
        self.pet:feed()
    elseif key == "p" then
        self.pet:play()
    elseif key == "c" then
        self.pet:clean()
    elseif key == "s" then
        self.pet:sleep()
    elseif key == "m" then
        self.pet:medicine()
    end
end

function GameState:mousepressed(x, y, button)
    -- Handle UI clicks
    local action = self.ui:handleClick(x, y)
    
    if action == "feed" then
        self.pet:feed()
    elseif action == "play" then
        self.pet:play()
    elseif action == "clean" then
        self.pet:clean()
    elseif action == "sleep" then
        self.pet:sleep()
    elseif action == "medicine" then
        self.pet:medicine()
    end
end

return GameState
