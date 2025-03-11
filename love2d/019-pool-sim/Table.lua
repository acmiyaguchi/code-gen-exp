local Table = {}
Table.__index = Table

function Table:new(world)
    local tableObj = {}
    setmetatable(tableObj, self)
    
    -- Visual properties
    tableObj.width = 700
    tableObj.height = 400
    tableObj.x = 50
    tableObj.y = 50
    tableObj.color = {0.1, 0.5, 0.1}  -- Green felt
    tableObj.cushionColor = {0.5, 0.3, 0.1}  -- Brown cushion
    
    -- Create table boundaries (cushions)
    tableObj.edges = {}
    
    -- Define the edge coordinates (top, right, bottom, left)
    local edges = {
        -- Top left to top right
        {tableObj.x + 30, tableObj.y, tableObj.x + tableObj.width/2 - 20, tableObj.y},
        {tableObj.x + tableObj.width/2 + 20, tableObj.y, tableObj.x + tableObj.width - 30, tableObj.y},
        
        -- Top right to bottom right
        {tableObj.x + tableObj.width, tableObj.y + 30, tableObj.x + tableObj.width, tableObj.y + tableObj.height/2 - 20},
        {tableObj.x + tableObj.width, tableObj.y + tableObj.height/2 + 20, tableObj.x + tableObj.width, tableObj.y + tableObj.height - 30},
        
        -- Bottom right to bottom left
        {tableObj.x + tableObj.width - 30, tableObj.y + tableObj.height, tableObj.x + tableObj.width/2 + 20, tableObj.y + tableObj.height},
        {tableObj.x + tableObj.width/2 - 20, tableObj.y + tableObj.height, tableObj.x + 30, tableObj.y + tableObj.height},
        
        -- Bottom left to top left
        {tableObj.x, tableObj.y + tableObj.height - 30, tableObj.x, tableObj.y + tableObj.height/2 + 20},
        {tableObj.x, tableObj.y + tableObj.height/2 - 20, tableObj.x, tableObj.y + 30}
    }
    
    for _, v in ipairs(edges) do
        local edge = {}
        edge.body = love.physics.newBody(world, 0, 0, "static")
        edge.shape = love.physics.newEdgeShape(v[1], v[2], v[3], v[4])
        edge.fixture = love.physics.newFixture(edge.body, edge.shape)
        edge.fixture:setRestitution(0.8)  -- Bouncy cushions
        edge.fixture:setFriction(0.2)
        table.insert(tableObj.edges, edge)
    end
    
    -- Create pockets (6 pockets at corners and mid-points of long sides)
    tableObj.pockets = {}
    local pocketPositions = {
        {tableObj.x, tableObj.y},                          -- Top left
        {tableObj.x + tableObj.width/2, tableObj.y},          -- Top middle
        {tableObj.x + tableObj.width, tableObj.y},            -- Top right
        {tableObj.x, tableObj.y + tableObj.height},           -- Bottom left
        {tableObj.x + tableObj.width/2, tableObj.y + tableObj.height}, -- Bottom middle
        {tableObj.x + tableObj.width, tableObj.y + tableObj.height}    -- Bottom right
    }
    
    for _, pos in ipairs(pocketPositions) do
        local pocket = {}
        pocket.body = love.physics.newBody(world, pos[1], pos[2], "static")
        pocket.shape = love.physics.newCircleShape(18)  -- Pocket radius
        pocket.fixture = love.physics.newFixture(pocket.body, pocket.shape)
        pocket.fixture:setSensor(true)  -- Pockets are sensors
        pocket.fixture:setUserData("pocket")
        table.insert(tableObj.pockets, pocket)
    end
    
    return tableObj
end

function Table:draw()
    -- Draw table background
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw cushions
    love.graphics.setColor(self.cushionColor)
    love.graphics.setLineWidth(8)
    for _, edge in ipairs(self.edges) do
        local x1, y1, x2, y2 = edge.fixture:getShape():getPoints()
        love.graphics.line(x1, y1, x2, y2)
    end
    love.graphics.setLineWidth(1)
    
    -- Draw pockets
    love.graphics.setColor(0, 0, 0)
    for _, pocket in ipairs(self.pockets) do
        love.graphics.circle("fill", pocket.body:getX(), pocket.body:getY(), pocket.shape:getRadius())
    end
    
    -- Draw boundary line for placing the cue ball
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.line(self.x + self.width/4, self.y, self.x + self.width/4, self.y + self.height)
end

return Table
