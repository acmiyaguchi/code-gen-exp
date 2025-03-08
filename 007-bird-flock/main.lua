
-- Global table to store all bird objects
birds = {}

-- Helper functions
local function vectorAdd(v1, v2)
    return {x = v1.x + v2.x, y = v1.y + v2.y}
end

local function vectorSubtract(v1, v2)
    return {x = v1.x - v2.x, y = v1.y - v2.y}
end

local function vectorMultiply(v, scalar)
    return {x = v.x * scalar, y = v.y * scalar}
end

local function vectorMagnitude(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

local function vectorNormalize(v)
    local mag = vectorMagnitude(v)
    if mag == 0 then
        return {x = 0, y = 0}
    else
        return {x = v.x / mag, y = v.y / mag}
    end
end

local function limitVector(v, max)
    local mag = vectorMagnitude(v)
    if mag > max then
        return vectorMultiply(vectorNormalize(v), max)
    else
        return v
    end
end

local function calculateSeparation(bird, otherBirds)
    local steering = {x = 0, y = 0}
    local count = 0
    for _, other in ipairs(otherBirds) do
        local distance = vectorMagnitude(vectorSubtract(bird, other))
        if distance > 0 and distance < bird.perceptionRadius then
            local diff = vectorNormalize(vectorSubtract(bird, other))
            diff = vectorMultiply(diff, 1 / distance)
            steering = vectorAdd(steering, diff)
            count = count + 1
        end
    end
    if count > 0 then
        steering = vectorMultiply(steering, 1 / count)
        steering = vectorMultiply(vectorNormalize(steering), bird.maxSpeed)
        steering = vectorSubtract(steering, {x = bird.velocityX, y = bird.velocityY})
        steering = limitVector(steering, bird.maxForce)
    end
    return steering
end

local function calculateAlignment(bird, otherBirds)
    local sum = {x = 0, y = 0}
    local count = 0
    for _, other in ipairs(otherBirds) do
        local distance = vectorMagnitude(vectorSubtract(bird, other))
        if distance > 0 and distance < bird.perceptionRadius then
            sum = vectorAdd(sum, {x = other.velocityX, y = other.velocityY})
            count = count + 1
        end
    end
    if count > 0 then
        sum = vectorMultiply(sum, 1 / count)
        sum = vectorMultiply(vectorNormalize(sum), bird.maxSpeed)
        local steering = vectorSubtract(sum, {x = bird.velocityX, y = bird.velocityY})
        return limitVector(steering, bird.maxForce)
    else
        return {x = 0, y = 0}
    end
end

local function calculateCohesion(bird, otherBirds)
    local sum = {x = 0, y = 0}
    local count = 0
    for _, other in ipairs(otherBirds) do
        local distance = vectorMagnitude(vectorSubtract(bird, other))
        if distance > 0 and distance < bird.perceptionRadius then
            sum = vectorAdd(sum, {x = other.x, y = other.y})
            count = count + 1
        end
    end
    if count > 0 then
        sum = vectorMultiply(sum, 1 / count)
        local desired = vectorSubtract(sum, {x = bird.x, y = bird.y})
        desired = vectorMultiply(vectorNormalize(desired), bird.maxSpeed)
        local steering = vectorSubtract(desired, {x = bird.velocityX, y = bird.velocityY})
        return limitVector(steering, bird.maxForce)
    else
        return {x = 0, y = 0}
    end
end

function love.load()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    for i = 1, 50 do
        table.insert(birds, {
            x = math.random(screenWidth),
            y = math.random(screenHeight),
            velocityX = math.random(-50, 50),
            velocityY = math.random(-50, 50),
            maxSpeed = 100,
            maxForce = 5,
            perceptionRadius = 50
        })
    end
end

function love.update(dt)
    for _, bird in ipairs(birds) do
        local separation = calculateSeparation(bird, birds)
        local alignment = calculateAlignment(bird, birds)
        local cohesion = calculateCohesion(bird, birds)

        local acceleration = vectorAdd(
            vectorAdd(vectorMultiply(separation, 2.0), vectorMultiply(alignment, 1.0)),
            vectorMultiply(cohesion, 1.0)
        )

        bird.velocityX = bird.velocityX + acceleration.x * dt
        bird.velocityY = bird.velocityY + acceleration.y * dt

        local velocity = {x = bird.velocityX, y = bird.velocityY}
        velocity = limitVector(velocity, bird.maxSpeed)
        bird.velocityX = velocity.x
        bird.velocityY = velocity.y

        bird.x = bird.x + bird.velocityX * dt
        bird.y = bird.y + bird.velocityY * dt

        if bird.x > love.graphics.getWidth() then bird.x = 0 end
        if bird.x < 0 then bird.x = love.graphics.getWidth() end
        if bird.y > love.graphics.getHeight() then bird.y = 0 end
        if bird.y < 0 then bird.y = love.graphics.getHeight() end
    end
end

function love.draw()
    for _, bird in ipairs(birds) do
        local angle = math.atan2(bird.velocityY, bird.velocityX)
        local cosA = math.cos(angle)
        local sinA = math.sin(angle)
        local points = {
            bird.x + 10 * cosA, bird.y + 10 * sinA,
            bird.x - 5 * cosA + 5 * sinA, bird.y - 5 * sinA - 5 * cosA,
            bird.x - 5 * cosA - 5 * sinA, bird.y - 5 * sinA + 5 * cosA
        }
        love.graphics.setColor(1, 0, 0)
        love.graphics.polygon("fill", points)
    end
end
