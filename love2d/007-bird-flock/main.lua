local Bird = {}
Bird.__index = Bird

function Bird:new(x, y)
    local bird = setmetatable({}, Bird)
    bird.position = {x = x, y = y}
    bird.velocity = {x = love.math.random(-1, 1), y = love.math.random(-1, 1)}
    bird.acceleration = {x = 0, y = 0}
    return bird
end

function Bird:update(birds, params)
    self:applyBehaviors(birds, params)
    self:move(params)
    self:wrapAroundScreen()
end

function Bird:applyBehaviors(birds, params)
    local separation = self:separate(birds, params.separationRadius)
    local alignment = self:align(birds, params.alignmentRadius, params)
    local cohesion = self:cohere(birds, params.cohesionRadius)

    self.acceleration.x = self.acceleration.x + separation.x * params.separationWeight
    self.acceleration.y = self.acceleration.y + separation.y * params.separationWeight
    self.acceleration.x = self.acceleration.x + alignment.x * params.alignmentWeight
    self.acceleration.y = self.acceleration.y + alignment.y * params.alignmentWeight
    self.acceleration.x = self.acceleration.x + cohesion.x * params.cohesionWeight
    self.acceleration.y = self.acceleration.y + cohesion.y * params.cohesionWeight
end

function Bird:move(params)
    self.velocity.x = self.velocity.x + self.acceleration.x
    self.velocity.y = self.velocity.y + self.acceleration.y

    local speed = math.sqrt(self.velocity.x^2 + self.velocity.y^2)
    if speed > params.maxSpeed then
        self.velocity.x = (self.velocity.x / speed) * params.maxSpeed
        self.velocity.y = (self.velocity.y / speed) * params.maxSpeed
    end

    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y

    self.acceleration.x = 0
    self.acceleration.y = 0
end

function Bird:wrapAroundScreen()
    if self.position.x < 0 then self.position.x = love.graphics.getWidth() end
    if self.position.x > love.graphics.getWidth() then self.position.x = 0 end
    if self.position.y < 0 then self.position.y = love.graphics.getHeight() end
    if self.position.y > love.graphics.getHeight() then self.position.y = 0 end
end

function Bird:separate(birds, radius)
    local steer = {x = 0, y = 0}
    local count = 0
    for _, other in ipairs(birds) do
        local d = self:distance(other)
        if d > 0 and d < radius then
            local diff = {x = self.position.x - other.position.x, y = self.position.y - other.position.y}
            diff.x = diff.x / d
            diff.y = diff.y / d
            steer.x = steer.x + diff.x
            steer.y = steer.y + diff.y
            count = count + 1
        end
    end
    if count > 0 then
        steer.x = steer.x / count
        steer.y = steer.y / count
    end
    return steer
end

function Bird:align(birds, radius, params)
    local sum = {x = 0, y = 0}
    local count = 0
    for _, other in ipairs(birds) do
        local d = self:distance(other)
        if d > 0 and d < radius then
            sum.x = sum.x + other.velocity.x
            sum.y = sum.y + other.velocity.y
            count = count + 1
        end
    end
    if count > 0 then
        sum.x = sum.x / count
        sum.y = sum.y / count
        local speed = math.sqrt(sum.x^2 + sum.y^2)
        if speed > 0 then
            sum.x = (sum.x / speed) * params.maxSpeed
            sum.y = (sum.y / speed) * params.maxSpeed
        end
    end
    return sum
end

function Bird:cohere(birds, radius)
    local sum = {x = 0, y = 0}
    local count = 0
    for _, other in ipairs(birds) do
        local d = self:distance(other)
        if d > 0 and d < radius then
            sum.x = sum.x + other.position.x
            sum.y = sum.y + other.position.y
            count = count + 1
        end
    end
    if count > 0 then
        sum.x = sum.x / count
        sum.y = sum.y / count
        return {x = sum.x - self.position.x, y = sum.y - self.position.y}
    else
        return {x = 0, y = 0}
    end
end

function Bird:distance(other)
    return math.sqrt((self.position.x - other.position.x)^2 + (self.position.y - other.position.y)^2)
end

function Bird:draw()
    love.graphics.circle("fill", self.position.x, self.position.y, 5)
end

local birds = {}
local params = {
    separationRadius = 25,
    alignmentRadius = 50,
    cohesionRadius = 50,
    separationWeight = 1.5,
    alignmentWeight = 1.0,
    cohesionWeight = 1.0,
    maxSpeed = 2
}

local timer = 0

function love.load()
    restartSimulation()
end

function love.update(dt)
    timer = timer + dt
    for _, bird in ipairs(birds) do
        bird:update(birds, params)
    end
end

function love.draw()
    for _, bird in ipairs(birds) do
        bird:draw()
    end
    love.graphics.print("Timer: " .. string.format("%.2f", timer), 10, 10)
end

function love.keypressed(key)
    if key == "r" then
        restartSimulation()
    end
end

function restartSimulation()
    birds = {}
    for i = 1, 100 do
        table.insert(birds, Bird:new(love.math.random(0, love.graphics.getWidth()), love.math.random(0, love.graphics.getHeight())))
    end
    timer = 0
end
