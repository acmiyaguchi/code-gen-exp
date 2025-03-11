local Player = {}
Player.__index = Player

function Player:new(cueBall)
    local player = {}
    setmetatable(player, self)
    
    player.cueBall = cueBall
    player.aiming = false
    player.power = 0
    player.maxPower = 300  -- Reduced from 1000 to 300
    player.angle = 0
    player.cueLength = 150
    player.spin = 0  -- For english (side spin)
    
    -- Coordinates for aiming
    player.startX = 0
    player.startY = 0
    player.endX = 0
    player.endY = 0
    
    return player
end

function Player:update(dt)
    if not self.aiming then
        -- Update aim line to follow mouse when not actively aiming
        local mx, my = love.mouse.getPosition()
        local ballX, ballY = self.cueBall.body:getPosition()
        
        -- Calculate angle between ball and mouse
        self.angle = math.atan2(my - ballY, mx - ballX)
    end
end

function Player:draw()
    local ballX, ballY = self.cueBall.body:getPosition()
    
    -- Draw aim line
    love.graphics.setColor(1, 1, 1, 0.6)
    
    -- Draw from the ball to opposite the mouse position (for showing direction)
    local lineLength = 200
    local endX = ballX - math.cos(self.angle) * lineLength
    local endY = ballY - math.sin(self.angle) * lineLength
    
    love.graphics.setLineWidth(1)
    love.graphics.line(ballX, ballY, endX, endY)
    
    -- Draw cue stick
    if self.aiming then
        love.graphics.setColor(0.8, 0.6, 0.2)
        local cueDistance = 10 + self.power / 10  -- Pull back cue based on power
        local cueStartX = ballX + math.cos(self.angle) * cueDistance
        local cueStartY = ballY + math.sin(self.angle) * cueDistance
        local cueEndX = cueStartX + math.cos(self.angle) * self.cueLength
        local cueEndY = cueStartY + math.sin(self.angle) * self.cueLength
        
        love.graphics.setLineWidth(4)
        love.graphics.line(cueStartX, cueStartY, cueEndX, cueEndY)
        
        -- Draw power indicator
        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.rectangle("fill", 10, 30, (self.power / self.maxPower) * 200, 15)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 10, 30, 200, 15)
        love.graphics.print("Power", 10, 15)
        
        -- Draw spin indicator
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Spin: " .. (self.spin > 0 and "Right" or (self.spin < 0 and "Left" or "None")), 10, 60)
    end
    
    love.graphics.setLineWidth(1)
end

function Player:mousepressed(x, y, button)
    if button == 1 then  -- Left click
        local ballX, ballY = self.cueBall.body:getPosition()
        self.startX = x
        self.startY = y
        self.endX = x
        self.endY = y
        self.power = 0
        self.aiming = true
        
        -- Calculate initial angle
        self.angle = math.atan2(y - ballY, x - ballX)
    end
end

function Player:mousereleased(x, y, button)
    if button == 1 and self.aiming then  -- Left click release
        self.endX = x
        self.endY = y
        
        -- Apply force to the ball
        local ballX, ballY = self.cueBall.body:getPosition()
        
        -- Create a force in the direction opposite of the angle
        local forceX = math.cos(self.angle) * -self.power
        local forceY = math.sin(self.angle) * -self.power
        
        self.cueBall:applyImpulse(forceX, forceY, self.spin * 5)
        
        self.aiming = false
        return true  -- Shot was taken
    end
    return false
end

function Player:mousemoved(x, y, dx, dy)
    if self.aiming then
        local ballX, ballY = self.cueBall.body:getPosition()
        
        -- Update aim angle
        self.angle = math.atan2(y - ballY, x - ballX)
        
        -- Calculate power based on distance from start position
        local distX = x - self.startX
        local distY = y - self.startY
        local distance = math.sqrt(distX * distX + distY * distY)
        
        -- Limit power to maxPower with reduced factor (2 instead of 5)
        self.power = math.min(distance * 2, self.maxPower)
    end
end

function Player:keypressed(key)
    -- Apply english (side spin)
    if key == "left" then
        self.spin = -1
    elseif key == "right" then
        self.spin = 1
    elseif key == "down" then
        self.spin = 0
    end
end

return Player
