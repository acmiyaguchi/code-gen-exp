function love.load()
    -- Window setup
    love.window.setTitle("Vectorized Whale")
    
    -- Colors
    whaleColor = {0, 105/255, 148/255}  -- Deep blue
    waterColor = {173/255, 216/255, 230/255}  -- Light blue
    
    -- Animation parameters
    time = 0
    waveAmplitude = 5
    waveSpeed = 1
end

function love.update(dt)
    -- Update time for animations
    time = time + dt
end

function love.draw()
    -- Draw background (water)
    love.graphics.setBackgroundColor(waterColor)
    
    -- Get window dimensions
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Position the whale in the center of the screen
    local whaleX = width / 2
    local whaleY = height / 2
    
    -- Calculate slight vertical movement for swimming effect
    local yOffset = math.sin(time * waveSpeed) * waveAmplitude
    
    -- Draw the whale
    drawWhale(whaleX, whaleY + yOffset, 200)  -- 200 is the base size factor
    
    -- Draw some bubbles
    drawBubbles(whaleX, whaleY, time)
end

function drawWhale(x, y, size)
    love.graphics.setColor(whaleColor)
    
    -- Main body (large oval)
    local bodyWidth = size * 1.5
    local bodyHeight = size * 0.5
    love.graphics.ellipse("fill", x, y, bodyWidth, bodyHeight)
    
    -- Head (smaller oval connected to the body)
    local headWidth = size * 0.4
    local headHeight = size * 0.3
    local headX = x - bodyWidth * 0.7
    local headY = y - bodyHeight * 0.1
    love.graphics.ellipse("fill", headX, headY, headWidth, headHeight)
    
    -- Tail fin
    local tailX = x + bodyWidth * 0.9
    local tailY = y
    love.graphics.polygon("fill", 
        tailX, tailY - bodyHeight * 0.5,
        tailX + size * 0.5, tailY - size * 0.6, 
        tailX + size * 0.3, tailY,
        tailX + size * 0.5, tailY + size * 0.6,
        tailX, tailY + bodyHeight * 0.5
    )
    
    -- Top fin (dorsal fin)
    local finX = x + size * 0.1
    local finY = y - bodyHeight * 0.9
    love.graphics.polygon("fill",
        x, y - bodyHeight * 0.7,
        x + size * 0.1, y - bodyHeight * 1.2,
        x + size * 0.3, y - bodyHeight * 0.7
    )
    
    -- Eye
    love.graphics.setColor(1, 1, 1)  -- White
    local eyeX = headX + headWidth * 0.3
    local eyeY = headY - headHeight * 0.2
    local eyeSize = size * 0.05
    love.graphics.circle("fill", eyeX, eyeY, eyeSize)
    
    love.graphics.setColor(0, 0, 0)  -- Black pupil
    love.graphics.circle("fill", eyeX + eyeSize * 0.3, eyeY, eyeSize * 0.5)
    
    -- Mouth line
    love.graphics.setLineWidth(2)
    love.graphics.line(
        headX - headWidth * 0.9, headY + headHeight * 0.3,
        headX - headWidth * 0.2, headY + headHeight * 0.4
    )
    
    -- Pectoral fin
    love.graphics.setColor(whaleColor)
    love.graphics.polygon("fill",
        x - bodyWidth * 0.2, y + bodyHeight * 0.4,
        x, y + bodyHeight * 0.8,
        x + bodyWidth * 0.2, y + bodyHeight * 0.6,
        x + size * 0.1, y + bodyHeight * 0.2
    )
    
    -- Blow hole
    love.graphics.circle("fill", x - bodyWidth * 0.3, y - bodyHeight * 0.8, size * 0.03)
end

function drawBubbles(whaleX, whaleY, time)
    love.graphics.setColor(1, 1, 1, 0.7)  -- Translucent white
    
    -- Generate some bubbles from the blow hole
    local blowHoleX = whaleX - 200 * 0.3
    local blowHoleY = whaleY - 100 * 0.8
    
    for i = 1, 8 do
        local offset = i * 40
        local bubbleY = blowHoleY - offset - math.sin(time * 2 + i) * 5
        local bubbleX = blowHoleX + math.cos(time + i) * 10
        local size = 3 + math.sin(time + i * 0.5) * 2
        
        love.graphics.circle("fill", bubbleX, bubbleY, size)
    end
    
    -- Some random bubbles around the whale
    for i = 1, 5 do
        local bubbleX = whaleX + math.cos(time * 0.5 + i * 50) * 250
        local bubbleY = whaleY + math.sin(time * 0.7 + i * 30) * 100
        local size = 2 + math.sin(time + i) * 1
        
        love.graphics.circle("fill", bubbleX, bubbleY, size)
    end
end
