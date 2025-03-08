-- OutputLED class for the Digital Circuit Simulator

OutputLED = {}
OutputLED.__index = OutputLED

function OutputLED:new(x, y, label)
    local led = {}
    setmetatable(led, OutputLED)
    
    led.x = x
    led.y = y
    led.label = label or ""
    led.state = false
    led.radius = 15
    
    return led
end

function OutputLED:setInput(state)
    self.state = state
end

function OutputLED:getInputPosition()
    return self.x - self.radius * 2, self.y
end

function OutputLED:draw()
    -- Draw LED label
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.label, self.x - self.radius, self.y - self.radius * 2)
    
    -- Draw LED body
    if self.state then
        love.graphics.setColor(1, 0.8, 0) -- Bright yellow when ON
    else
        love.graphics.setColor(0.3, 0.3, 0.3) -- Dark gray when OFF
    end
    
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    -- Draw LED outline
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("line", self.x, self.y, self.radius)
    
    -- Draw LED state text
    love.graphics.setColor(0, 0, 0)
    if self.state then
        love.graphics.print("ON", self.x - 10, self.y - 8)
    else
        love.graphics.print("OFF", self.x - 12, self.y - 8)
    end
end

function OutputLED:update()
    -- LED state is updated via setInput method
end
