local stars = {}
local bigStar = {x = 400, y = 300, size = 50, speed = 0.4, angle = 0} -- Initialize angle

-- Load function to initialize the stars
function love.load()
    for i = 1, 100 do
        local star = {
            x = love.math.random(0, 800),
            y = love.math.random(0, 600),
            size = love.math.random(5, 15),
            speed = love.math.random() * 0.4 + 0.2,
            angle = love.math.random() * 2 * math.pi
        }
        table.insert(stars, star)
    end
end

-- Update function to update the angles of the stars
function love.update(dt)
    bigStar.angle = bigStar.angle + bigStar.speed * dt
    for _, star in ipairs(stars) do
        star.angle = star.angle + star.speed * dt
    end
end

-- Draw function to render the stars on the screen
function love.draw()
    drawStar(bigStar.x, bigStar.y, bigStar.size, bigStar.angle)
    for _, star in ipairs(stars) do
        drawStar(star.x, star.y, star.size, star.angle)
    end
end


-- Function to draw a star (Improved Version)
function drawStar(x, y, size, angle, points, innerRatio, mode, color)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)

    if color then
        love.graphics.setColor(color)
    end

    points = points or 5
    innerRatio = innerRatio or 0.5
    mode = mode or 'fill'

    local vertices = starVertices(size, points, innerRatio)
    love.graphics.polygon(mode, vertices)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1) -- Restore default color
end

-- Function to calculate the vertices of a star (Improved Version)
function starVertices(size, points, innerRatio)
    local vertices = {}
    local angleStep = 2 * math.pi / points
    for i = 0, points - 1 do
        local outerAngle = (i * angleStep) - math.pi / 2
        local innerAngle = ((i + 0.5) * angleStep) - math.pi / 2

        -- Outer point
        table.insert(vertices, size * math.cos(outerAngle))
        table.insert(vertices, size * math.sin(outerAngle))

        -- Inner point
        if i < points then
          table.insert(vertices, (size * innerRatio) * math.cos(innerAngle))
          table.insert(vertices, (size * innerRatio) * math.sin(innerAngle))
        end
    end
    return vertices
end