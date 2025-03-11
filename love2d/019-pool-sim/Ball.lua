-- Ball.lua
-- Represents a pool ball with physics properties and rendering

local Ball = {}
Ball.__index = Ball

--[[
    Creates a new ball with physics properties
    
    @param world - The physics world to add the ball to
    @param x, y - Initial position
    @param radius - Ball radius 
    @param color - RGB color table
    @param number - Ball number (0 for cue ball)
    @return Ball instance
]]
function Ball:new(world, x, y, radius, color, number)
    local ball = {}
    setmetatable(ball, self)
    
    -- Create physics body
    ball.body = love.physics.newBody(world, x, y, "dynamic")
    ball.shape = love.physics.newCircleShape(radius)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape)
    ball.fixture:setRestitution(0.9)  -- Bouncy
    ball.fixture:setFriction(0.4)     -- Some friction
    ball.body:setLinearDamping(1.0)   -- Slows linear movement
    ball.body:setAngularDamping(0.8)  -- Slows rotation
    
    -- Set user data for collision detection
    ball.fixture:setUserData({type = "ball", object = ball})
    
    -- Visual properties
    ball.color = color
    ball.number = number
    ball.radius = radius
    ball.pocketed = false
    
    -- Store initial position for resets
    ball.initialX = x
    ball.initialY = y
    
    return ball
end

--[[
    Updates ball state
    Stops the ball if it's moving very slowly
]]
function Ball:update(dt)
    -- If we're going very slow, just stop completely
    local vx, vy = self.body:getLinearVelocity()
    local speed = math.sqrt(vx*vx + vy*vy)
    if speed < 5 then
        self.body:setLinearVelocity(0, 0)
        self.body:setAngularVelocity(0)
    end
end

--[[
    Renders the ball with its number
]]
function Ball:draw()
    -- Draw ball background
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.radius)
    
    -- Draw ball outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", self.body:getX(), self.body:getY(), self.radius)
    
    -- Draw number if not the cue ball
    if self.number > 0 then
        love.graphics.setColor(1, 1, 1)
        
        -- Determine horizontal offset based on number of digits
        local offset = 3
        if self.number >= 10 then
            offset = 6
        end
        
        love.graphics.print(self.number, self.body:getX() - offset, self.body:getY() - 5)
    end
end

--[[
    Applies force to the ball
    
    @param fx, fy - Force vector components
    @param spin - Optional rotational force
]]
function Ball:applyImpulse(fx, fy, spin)
    -- Apply a scaling factor to reduce the impulse force
    local scaleFactor = 0.2  -- Reduce force to 20% of original
    self.body:applyLinearImpulse(fx * scaleFactor, fy * scaleFactor)
    
    if spin then
        -- Reduce the spin effect as well
        self.body:setAngularVelocity(spin * 0.5)
    end
end

--[[
    Checks if the ball is still moving
    @return boolean - true if the ball is moving
]]
function Ball:isMoving()
    local vx, vy = self.body:getLinearVelocity()
    local speed = math.sqrt(vx*vx + vy*vy)
    return speed > 1
end

--[[
    Resets the ball to its initial position or a specified position
    @param x, y - Optional new position
]]
function Ball:reset(x, y)
    self.body:setPosition(x or self.initialX, y or self.initialY)
    self.body:setLinearVelocity(0, 0)
    self.body:setAngularVelocity(0)
    self.pocketed = false
end

return Ball
