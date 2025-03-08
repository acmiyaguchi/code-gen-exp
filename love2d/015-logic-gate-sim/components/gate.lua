-- Gate classes for the Digital Circuit Simulator

Gate = {}
Gate.__index = Gate

function Gate:new(x, y, type)
    local gate = {}
    setmetatable(gate, Gate)
    
    gate.x = x
    gate.y = y
    gate.type = type or "UNKNOWN"
    gate.inputs = {false, false}  -- Default inputs (binary gates)
    gate.output = false
    gate.outputWire = nil
    gate.width = 60
    gate.height = 40
    
    return gate
end

function Gate:setInput(state, index)
    if index >= 1 and index <= #self.inputs then
        self.inputs[index] = state
        self:updateOutput()
    end
end

function Gate:connectOutput(wire)
    self.outputWire = wire
end

function Gate:updateOutput()
    -- Each gate type will override this method
    -- to implement its specific logic
end

function Gate:getOutputPosition()
    -- Output is on the right side of the gate
    return self.x + self.width, self.y + self.height / 2
end

function Gate:getInputPosition(index)
    -- Inputs are on the left side of the gate
    local inputCount = #self.inputs
    local spacing = self.height / (inputCount + 1)
    return self.x, self.y + index * spacing
end

function Gate:draw()
    -- Draw gate body
    if self.output then
        love.graphics.setColor(0.8, 0.8, 0.2) -- Yellow when ON
    else
        love.graphics.setColor(0.4, 0.4, 0.4) -- Gray when OFF
    end
    
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw gate outline
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw gate label
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.type, self.x + 10, self.y + self.height / 2 - 10)
    
    -- Draw input nodes
    for i = 1, #self.inputs do
        if self.inputs[i] then
            love.graphics.setColor(1, 0.5, 0) -- Orange when ON
        else
            love.graphics.setColor(0.3, 0.3, 0.3) -- Dark gray when OFF
        end
        
        local ix, iy = self:getInputPosition(i)
        love.graphics.circle("fill", ix, iy, 5)
    end
    
    -- Draw output node
    if self.output then
        love.graphics.setColor(1, 0.5, 0) -- Orange when ON
    else
        love.graphics.setColor(0.3, 0.3, 0.3) -- Dark gray when OFF
    end
    
    local ox, oy = self:getOutputPosition()
    love.graphics.circle("fill", ox, oy, 5)
end

function Gate:update()
    -- Gate states are updated via setInput and updateOutput methods
end

-- ANDGate implementation
ANDGate = {}
setmetatable(ANDGate, {__index = Gate})
ANDGate.__index = ANDGate

function ANDGate:new(x, y)
    local gate = Gate:new(x, y, "AND")
    setmetatable(gate, ANDGate)
    return gate
end

function ANDGate:updateOutput()
    -- AND gate logic: output is true only if all inputs are true
    local result = true
    for i, input in ipairs(self.inputs) do
        if not input then
            result = false
            break
        end
    end
    
    self.output = result
    if self.outputWire then
        self.outputWire:setState(result)
    end
end

-- ORGate implementation
ORGate = {}
setmetatable(ORGate, {__index = Gate})
ORGate.__index = ORGate

function ORGate:new(x, y)
    local gate = Gate:new(x, y, "OR")
    setmetatable(gate, ORGate)
    return gate
end

function ORGate:updateOutput()
    -- OR gate logic: output is true if any input is true
    local result = false
    for i, input in ipairs(self.inputs) do
        if input then
            result = true
            break
        end
    end
    
    self.output = result
    if self.outputWire then
        self.outputWire:setState(result)
    end
end

-- NOTGate implementation
NOTGate = {}
setmetatable(NOTGate, {__index = Gate})
NOTGate.__index = NOTGate

function NOTGate:new(x, y)
    local gate = Gate:new(x, y, "NOT")
    setmetatable(gate, NOTGate)
    gate.inputs = {false}  -- NOT gate has only one input
    return gate
end

function NOTGate:updateOutput()
    -- NOT gate logic: output is the inverse of input
    local result = not self.inputs[1]
    
    self.output = result
    if self.outputWire then
        self.outputWire:setState(result)
    end
end

-- XORGate implementation
XORGate = {}
setmetatable(XORGate, {__index = Gate})
XORGate.__index = XORGate

function XORGate:new(x, y)
    local gate = Gate:new(x, y, "XOR")
    setmetatable(gate, XORGate)
    return gate
end

function XORGate:updateOutput()
    -- XOR gate logic: output is true if inputs have different values
    local count = 0
    for i, input in ipairs(self.inputs) do
        if input then
            count = count + 1
        end
    end
    
    local result = (count == 1)  -- XOR is true when exactly one input is true
    
    self.output = result
    if self.outputWire then
        self.outputWire:setState(result)
    end
end
