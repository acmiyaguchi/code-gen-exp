-- Circuit class for the Digital Circuit Simulator

Circuit = {}
Circuit.__index = Circuit

function Circuit:new()
    local circuit = {}
    setmetatable(circuit, Circuit)
    
    circuit.components = {}
    circuit.inputs = {}
    circuit.outputs = {}
    circuit.gates = {}
    circuit.wires = {}
    
    return circuit
end

function Circuit:add(component)
    table.insert(self.components, component)
    
    -- Also store component in the appropriate specific list
    if getmetatable(component) == InputSwitch then
        table.insert(self.inputs, component)
    elseif getmetatable(component) == OutputLED then
        table.insert(self.outputs, component)
    elseif getmetatable(component) == Wire then
        table.insert(self.wires, component)
    else
        -- Must be a gate or gate subclass
        table.insert(self.gates, component)
    end
end

function Circuit:update(dt)
    -- Update the circuit state with proper signal propagation
    -- We'll use a simple approach since our circuit is small
    
    -- First update gates
    for i, gate in ipairs(self.gates) do
        gate:update()
    end
    
    -- Then update outputs
    for i, output in ipairs(self.outputs) do
        output:update()
    end
end

function Circuit:draw()
    -- Draw each component
    
    -- Draw wires first so they appear beneath components
    for i, wire in ipairs(self.wires) do
        wire:draw()
    end
    
    -- Draw gates
    for i, gate in ipairs(self.gates) do
        gate:draw()
    end
    
    -- Draw inputs
    for i, input in ipairs(self.inputs) do
        input:draw()
    end
    
    -- Draw outputs
    for i, output in ipairs(self.outputs) do
        output:draw()
    end
end

function Circuit:handleClick(x, y, button)
    -- Check if any input switch was clicked
    for i, input in ipairs(self.inputs) do
        if input:isClicked(x, y) then
            input:toggle()
            return true
        end
    end
    
    return false
end

function Circuit:clear()
    self.components = {}
    self.inputs = {}
    self.outputs = {}
    self.gates = {}
    self.wires = {}
end
