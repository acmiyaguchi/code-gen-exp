-- Digital Circuit Simulator

-- Load component classes
require("components/wire")
require("components/gate")
require("components/input_switch")
require("components/output_led")
require("components/circuit")

-- Global variables
local circuit

function love.load()
    -- Initialize the circuit
    circuit = Circuit:new()
    
    -- Set up the example circuit from the design document:
    -- Input A --\
    --            |--- AND Gate --- Output X
    -- Input B --/
    --            |--- OR Gate --- Output Y
    -- Input C --/--- NOT Gate ---/
    
    -- Create inputs
    local inputA = InputSwitch:new(100, 100, "A")
    local inputB = InputSwitch:new(100, 200, "B")
    local inputC = InputSwitch:new(100, 300, "C")
    
    -- Create gates
    local andGate = ANDGate:new(300, 150)
    local orGate = ORGate:new(300, 250)
    local notGate = NOTGate:new(300, 350)
    
    -- Create outputs
    local outputX = OutputLED:new(500, 150, "X")
    local outputY = OutputLED:new(500, 250, "Y")
    
    -- Create wires
    local wireA_AND = Wire:new()
    local wireB_AND = Wire:new()
    local wireB_OR = Wire:new()
    local wireC_OR = Wire:new()
    local wireC_NOT = Wire:new()
    local wireAND_X = Wire:new()
    local wireOR_Y = Wire:new()
    local wireNOT_OR = Wire:new()
    
    -- Connect inputs to gates
    inputA:connectOutput(wireA_AND)
    wireA_AND:connect(inputA, andGate, 1)
    
    inputB:connectOutput(wireB_AND)
    wireB_AND:connect(inputB, andGate, 2)
    
    inputB:connectOutput(wireB_OR)
    wireB_OR:connect(inputB, orGate, 1)
    
    inputC:connectOutput(wireC_NOT)
    wireC_NOT:connect(inputC, notGate, 1)
    
    inputC:connectOutput(wireC_OR)
    wireC_OR:connect(inputC, orGate, 2)
    
    -- Connect gates to outputs
    andGate:connectOutput(wireAND_X)
    wireAND_X:connect(andGate, outputX)
    
    orGate:connectOutput(wireOR_Y)
    wireOR_Y:connect(orGate, outputY)
    
    -- Connect NOT gate to OR gate
    notGate:connectOutput(wireNOT_OR)
    wireNOT_OR:connect(notGate, orGate, 2) -- This overrides the direct connection from inputC
    
    -- Add all components to the circuit
    circuit:add(inputA)
    circuit:add(inputB)
    circuit:add(inputC)
    circuit:add(andGate)
    circuit:add(orGate)
    circuit:add(notGate)
    circuit:add(outputX)
    circuit:add(outputY)
    circuit:add(wireA_AND)
    circuit:add(wireB_AND)
    circuit:add(wireB_OR)
    circuit:add(wireC_OR)
    circuit:add(wireC_NOT)
    circuit:add(wireAND_X)
    circuit:add(wireOR_Y)
    circuit:add(wireNOT_OR)
end

function love.update(dt)
    circuit:update(dt)
end

function love.draw()
    -- Set background color
    love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Digital Circuit Simulator", 10, 10)
    love.graphics.print("Click on input switches to toggle them", 10, 30)
    
    -- Draw the circuit
    circuit:draw()
end

function love.mousepressed(x, y, button)
    circuit:handleClick(x, y, button)
end
