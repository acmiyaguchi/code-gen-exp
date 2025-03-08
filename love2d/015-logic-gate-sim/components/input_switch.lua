-- InputSwitch class for the Digital Circuit Simulator

InputSwitch = {}
InputSwitch.__index = InputSwitch

function InputSwitch:new(x, y, label)
    local switch = {}
    setmetatable(switch, InputSwitch)
    
    switch.x = x
    switch.y = y
    switch.label = label or ""
    switch.state = false
    switch.outputWire = nil
    switch.radius = 15
    
    return switch
end

function InputSwitch:toggle()
    self.state = not self.state
    if self.outputWire then
        self.outputWire:setState(self.state)
    end
end

function InputSwitch:connectOutput(wire)
    self.outputWire = wire
    wire:setState(self.state)
end

function InputSwitch:getOutputPosition()
    return self.x + self.radius * 2, self.y
end

function InputSwitch:draw()
    -- Draw switch label
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.label, self.x - self.radius, self.y - self.radius * 2)
    
    -- Draw switch body
    if self.state then
        love.graphics.setColor(0, 0.8, 0) -- Green when ON
    else
        love.graphics.setColor(0.8, 0, 0) -- Red when OFF
    end
    
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    -- Draw switch outline
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("line", self.x, self.y, self.radius)
    
    -- Draw switch state text
    love.graphics.setColor(1, 1, 1)
    if self.state then
        love.graphics.print("ON", self.x - 10, self.y - 8)
    else
        love.graphics.print("OFF", self.x - 12, self.y - 8)
    end
end

function InputSwitch:update()
    -- Switch state is updated via toggle method
end

function InputSwitch:isClicked(mouseX, mouseY)
    -- Check if the mouse click is within the switch's circle
    local distX = mouseX - self.x
    local distY = mouseY - self.y
    local distance = math.sqrt(distX * distX + distY * distY)
    
    return distance <= self.radius
end
