-- Wire class for the Digital Circuit Simulator

Wire = {}
Wire.__index = Wire

function Wire:new()
    local wire = {}
    setmetatable(wire, Wire)
    
    wire.state = false
    wire.source = nil
    wire.destination = nil
    wire.destinationPort = nil
    
    return wire
end

function Wire:connect(source, destination, destinationPort)
    self.source = source
    self.destination = destination
    self.destinationPort = destinationPort
end

function Wire:setState(newState)
    if self.state ~= newState then
        self.state = newState
        if self.destination and self.destinationPort then
            -- If connecting to a gate input
            self.destination:setInput(newState, self.destinationPort)
        elseif self.destination then
            -- If connecting to an output LED
            self.destination:setInput(newState)
        end
    end
end

function Wire:getSourceCoordinates()
    if not self.source then return 0, 0 end
    
    if self.source.getOutputPosition then
        return self.source:getOutputPosition()
    else
        return self.source.x, self.source.y
    end
end

function Wire:getDestinationCoordinates()
    if not self.destination then return 0, 0 end
    
    if self.destination.getInputPosition and self.destinationPort then
        return self.destination:getInputPosition(self.destinationPort)
    else
        return self.destination.x, self.destination.y
    end
end

function Wire:draw()
    local sx, sy = self:getSourceCoordinates()
    local dx, dy = self:getDestinationCoordinates()
    
    -- Set color based on state
    if self.state then
        love.graphics.setColor(1, 0.5, 0) -- Orange/yellow for ON
    else
        love.graphics.setColor(0.3, 0.3, 0.3) -- Dark gray for OFF
    end
    
    -- Draw the wire line
    love.graphics.setLineWidth(2)
    love.graphics.line(sx, sy, dx, dy)
    love.graphics.setLineWidth(1)
end

function Wire:update()
    -- Wire doesn't need to update itself
end
