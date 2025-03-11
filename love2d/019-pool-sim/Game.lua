local Table = require 'Table'
local Ball = require 'Ball'
local Player = require 'Player'

local Game = {}
Game.__index = Game

function Game:new()
    local game = {}
    setmetatable(game, self)
    
    -- Initialize physics world (no gravity for top-down view)
    game.world = love.physics.newWorld(0, 0, true)
    game.world:setCallbacks(
        function(a, b) game:beginContact(a, b) end,
        function(a, b) game:endContact(a, b) end,
        nil, nil
    )
    
    -- Initialize table
    game.table = Table:new(game.world)
    
    -- Initialize balls
    game.balls = {}
    game.cueBall = Ball:new(game.world, 200, 250, 10, {1, 1, 1}, 0)
    table.insert(game.balls, game.cueBall)
    
    -- Create the 9 numbered balls in a diamond formation
    local ballColors = {
        {1, 1, 0},    -- 1: yellow
        {0, 0, 1},    -- 2: blue
        {1, 0, 0},    -- 3: red
        {0.6, 0, 0.8},-- 4: purple
        {1, 0.5, 0},  -- 5: orange
        {0, 0.8, 0},  -- 6: green
        {0.6, 0.3, 0},-- 7: brown
        {0, 0, 0},    -- 8: black
        {1, 1, 0.5}   -- 9: light yellow
    }
    
    -- Position for the first ball in the rack
    local rackX = 550
    local rackY = 250
    local radius = 10
    local spacing = radius * 2.1
    
    -- Create rack formation
    local row = 1
    local index = 1
    for i = 1, 5 do
        local offset = (row - 1) * radius
        for j = 1, row do
            if index <= 9 then
                local x = rackX + (i - 1) * spacing
                local y = rackY - offset + (j - 1) * spacing * 2
                local ball = Ball:new(game.world, x, y, radius, ballColors[index], index)
                table.insert(game.balls, ball)
                index = index + 1
            end
        end
        row = row + 1
    end
    
    -- Initialize player control
    game.player = Player:new(game.cueBall)
    
    -- Game state
    game.state = "aiming" -- aiming, shooting, waiting, gameover
    game.debugDraw = false
    game.pottedBalls = {}
    
    return game
end

function Game:update(dt)
    self.world:update(dt)
    
    -- Update all balls
    for i, ball in ipairs(self.balls) do
        ball:update(dt)
    end
    
    -- Check if balls are still moving
    local anyMoving = false
    for _, ball in ipairs(self.balls) do
        if ball:isMoving() then
            anyMoving = true
            break
        end
    end
    
    -- State management
    if self.state == "shooting" and not anyMoving then
        self.state = "aiming"
    elseif self.state == "waiting" and not anyMoving then
        -- Check for game over condition
        if #self.pottedBalls == 9 then
            self.state = "gameover"
        else
            self.state = "aiming"
        end
    end
    
    -- Update player controls if in aiming state
    if self.state == "aiming" then
        self.player:update(dt)
    end
    
    -- Remove pocketed balls from play
    for i = #self.balls, 1, -1 do
        if self.balls[i].pocketed and self.balls[i].number > 0 then
            table.insert(self.pottedBalls, self.balls[i].number)
            table.remove(self.balls, i)
        elseif self.balls[i].pocketed and self.balls[i].number == 0 then
            -- Reset cue ball if pocketed
            self.cueBall:reset(200, 250)
            self.state = "waiting"
        end
    end
end

function Game:draw()
    -- Draw table first
    self.table:draw()
    
    -- Draw balls
    for _, ball in ipairs(self.balls) do
        ball:draw()
    end
    
    -- Draw player cue and aiming line if in aiming state
    if self.state == "aiming" then
        self.player:draw()
    end
    
    -- Draw debug information if enabled
    if self.debugDraw then
        -- Draw physics bodies
        love.graphics.setColor(0, 1, 0, 0.5)
        for _, ball in ipairs(self.balls) do
            love.graphics.circle("line", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
            -- Draw velocity vector
            local vx, vy = ball.body:getLinearVelocity()
            love.graphics.line(
                ball.body:getX(), ball.body:getY(),
                ball.body:getX() + vx/5, ball.body:getY() + vy/5
            )
        end
        
        -- Draw table boundaries
        love.graphics.setColor(1, 0, 0, 0.5)
        for _, edge in ipairs(self.table.edges) do
            local x1, y1, x2, y2 = edge.fixture:getShape():getPoints()
            love.graphics.line(x1, y1, x2, y2)
        end
        
        -- Draw pocket sensors
        love.graphics.setColor(0, 0, 1, 0.5)
        for _, pocket in ipairs(self.table.pockets) do
            love.graphics.circle("line", pocket.body:getX(), pocket.body:getY(), pocket.shape:getRadius())
        end
    end
    
    -- Draw UI information
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Pool Physics Demo - R to Reset - D to Toggle Debug", 10, 10)
    
    if self.state == "gameover" then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
        love.graphics.rectangle("fill", 200, 200, 400, 100)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Game Over! Press R to Restart", 250, 240, 0, 2, 2)
    end
end

function Game:beginContact(fixtureA, fixtureB)
    local userData1 = fixtureA:getUserData()
    local userData2 = fixtureB:getUserData()
    
    -- Check for ball-pocket collisions
    if userData1 == "pocket" and userData2 and userData2.type == "ball" then
        userData2.object.pocketed = true
    elseif userData2 == "pocket" and userData1 and userData1.type == "ball" then
        userData1.object.pocketed = true
    end
end

function Game:endContact(fixtureA, fixtureB)
    -- Used for tracking when contacts end if needed
end

function Game:mousepressed(x, y, button)
    if self.state == "aiming" then
        self.player:mousepressed(x, y, button)
    end
end

function Game:mousereleased(x, y, button)
    if self.state == "aiming" then
        local shot = self.player:mousereleased(x, y, button)
        if shot then
            self.state = "shooting"
        end
    end
end

function Game:mousemoved(x, y, dx, dy)
    if self.state == "aiming" then
        self.player:mousemoved(x, y, dx, dy)
    end
end

function Game:keypressed(key)
    if self.state == "aiming" then
        self.player:keypressed(key)
    end
end

function Game:toggleDebug()
    self.debugDraw = not self.debugDraw
end

function Game:reset()
    -- Re-initialize the game
    local new = Game:new()
    for k, v in pairs(new) do
        self[k] = v
    end
end

return Game
