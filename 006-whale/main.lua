function love.load()
    -- Window setup
    love.window.setTitle("Realistic Whale")
    
    -- Enhanced color palette
    whaleMainColor = {0, 65/255, 106/255}  -- Deeper blue for main body
    whaleBellyColor = {180/255, 200/255, 215/255}  -- Lighter underside
    waterColor = {10/255, 30/255, 70/255, 1}  -- Deeper ocean blue
    waterSurfaceColor = {30/255, 70/255, 130/255, 0.7}  -- Surface highlight
    
    -- Animation parameters
    time = 0
    waveAmplitude = 5
    waveSpeed = 1
    
    -- Whale textures - tiny noise dots for skin texture
    whaleTexture = {}
    for i = 1, 300 do
        table.insert(whaleTexture, {
            x = love.math.random(),
            y = love.math.random(),
            size = love.math.random(1, 2)
        })
    end
    
    -- Create an underwater light effect
    lightRays = {}
    for i = 1, 15 do
        table.insert(lightRays, {
            x = love.math.random(0, love.graphics.getWidth()),
            width = love.math.random(50, 200),
            speed = love.math.random(10, 30) / 100
        })
    end
end

function love.update(dt)
    -- Update time for animations
    time = time + dt
    
    -- Update light rays
    for i, ray in ipairs(lightRays) do
        ray.x = ray.x + ray.speed * dt * 20
        if ray.x > love.graphics.getWidth() + ray.width then
            ray.x = -ray.width
        end
    end
end

function love.draw()
    -- Draw deep water background
    love.graphics.setBackgroundColor(waterColor)
    
    -- Draw light rays coming from the surface
    drawLightRays()
    
    -- Get window dimensions
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Position the whale in the center of the screen
    local whaleX = width / 2
    local whaleY = height / 2
    
    -- Calculate whale movement
    local yOffset = math.sin(time * waveSpeed) * waveAmplitude
    local xOffset = math.sin(time * waveSpeed * 0.5) * waveAmplitude * 0.5
    
    -- Draw the whale with subtle movement
    drawRealisticWhale(whaleX + xOffset, whaleY + yOffset, 200)
    
    -- Draw bubbles
    drawBubbles(whaleX, whaleY, time)
    
    -- Draw water surface effect at the top
    drawWaterSurface()
end

function drawLightRays()
    for _, ray in ipairs(lightRays) do
        -- Draw light rays coming from the top of the screen
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.polygon("fill", 
            ray.x - ray.width/2, 0, 
            ray.x + ray.width/2, 0,
            ray.x + ray.width*2, love.graphics.getHeight(),
            ray.x - ray.width*2, love.graphics.getHeight()
        )
    end
end

function drawWaterSurface()
    -- Draw a subtle water surface at the top of the screen
    love.graphics.setColor(waterSurfaceColor)
    local height = 80
    local segments = 20
    local width = love.graphics.getWidth()
    
    for i = 0, segments do
        local x1 = (i-1) * width / segments
        local y1 = height/2 + math.sin(time + (i-1) * 0.5) * height/4
        local x2 = i * width / segments
        local y2 = height/2 + math.sin(time + i * 0.5) * height/4
        
        love.graphics.polygon("fill", x1, 0, x2, 0, x2, y2, x1, y1)
    end
    
    -- Add foam/bubbles at the surface
    love.graphics.setColor(1, 1, 1, 0.3)
    for i = 1, 40 do
        local x = (i-1) * width / 40 + math.sin(time + i) * 5
        local y = height/3 + math.sin(time * 1.5 + i * 0.4) * height/5
        local size = 2 + math.sin(time + i) * 1
        love.graphics.circle("fill", x, y, size)
    end
end

function drawRealisticWhale(x, y, size)
    -- Draw the whale's shadow first
    love.graphics.setColor(0, 0, 0, 0.2)
    drawWhaleBody(x + 15, y + 25, size * 1.02, true)
    
    -- Draw the whale's underside/belly first
    love.graphics.setColor(whaleBellyColor)
    drawWhaleBelly(x, y, size)
    
    -- Draw the main body of the whale
    love.graphics.setColor(whaleMainColor)
    drawWhaleBody(x, y, size)
    
    -- Draw details
    drawWhaleDetails(x, y, size)
    
    -- Add subtle texture to whale's skin
    drawWhaleTexture(x, y, size)
end

function drawWhaleBody(x, y, size, isShadow)
    -- Refined body shape for blue whale
    local bodyWidth = size * 1.6
    local bodyHeight = size * 0.45
    
    -- Main body curve - more streamlined
    local points = {}
    local segments = 30
    
    for i = 0, segments do
        local angle = i / segments * math.pi
        local px = x - bodyWidth * math.cos(angle)
        
        -- Create more tapered head and tail with a curve function
        local tapering = 0.8 + 0.4 * math.sin(angle) -- This gives a fuller middle and tapered ends
        local py = y + bodyHeight * math.sin(angle) * tapering
        
        table.insert(points, px)
        table.insert(points, py)
    end
    
    -- Draw the smooth whale body
    love.graphics.polygon("fill", unpack(points))
    
    -- Dorsal fin - more curved and realistic
    if not isShadow then
        local finX = x + size * 0.2
        local finY = y - bodyHeight * 0.8
        local finPoints = {
            x + size * 0.05, y - bodyHeight * 0.7,
            x + size * 0.2, y - bodyHeight * 1.3,
            x + size * 0.4, y - bodyHeight * 0.65
        }
        
        -- Make the dorsal fin curve a bit
        for i = 1, #finPoints, 2 do
            local px, py = finPoints[i], finPoints[i+1]
            -- Add a slight curve
            finPoints[i] = px + math.sin((i/2) / 3 * math.pi) * size * 0.05
        end
        
        love.graphics.polygon("fill", unpack(finPoints))
    end
    
    -- Tail flukes - more detailed with curves
    local tailX = x + bodyWidth * 0.75
    local tailY = y
    local tailPoints = {
        tailX, tailY - bodyHeight * 0.3,
        tailX + size * 0.6, tailY - size * 0.6,
        tailX + size * 0.5, tailY - size * 0.2,
        tailX + size * 0.3, tailY,
        tailX + size * 0.5, tailY + size * 0.2,
        tailX + size * 0.6, tailY + size * 0.6,
        tailX, tailY + bodyHeight * 0.3
    }
    
    -- Make the tail curve a bit
    for i = 1, #tailPoints, 2 do
        local px, py = tailPoints[i], tailPoints[i+1]
        -- Add a wave to the tail
        tailPoints[i] = px + math.sin((i/2) / 7 * math.pi + time * 0.3) * size * 0.05
    end
    
    love.graphics.polygon("fill", unpack(tailPoints))
end

function drawWhaleBelly(x, y, size)
    -- Underside of the whale - lighter colored belly
    local bodyWidth = size * 1.6
    local bodyHeight = size * 0.45
    local bellyHeight = bodyHeight * 0.7
    
    local points = {}
    local segments = 30
    
    for i = 0, segments do
        local angle = i / segments * math.pi
        local px = x - bodyWidth * math.cos(angle)
        
        -- Only the bottom part of the whale
        local py = y + math.max(0, bellyHeight * math.sin(angle))
        
        table.insert(points, px)
        table.insert(points, py)
    end
    
    -- Close the shape along the middle of the whale
    table.insert(points, x - bodyWidth)
    table.insert(points, y)
    table.insert(points, x + bodyWidth)
    table.insert(points, y)
    
    -- Draw the belly
    love.graphics.polygon("fill", unpack(points))
    
    -- Pectoral fins - more detailed and curved
    local finPoints = {
        x - bodyWidth * 0.2, y + bodyHeight * 0.3,
        x, y + bodyHeight * 0.7,
        x + bodyWidth * 0.15, y + bodyHeight * 0.5,
        x + bodyWidth * 0.05, y + bodyHeight * 0.2
    }
    
    -- Make the fin curve a bit
    for i = 1, #finPoints, 2 do
        local px, py = finPoints[i], finPoints[i+1]
        -- Add slight wave motion to fin
        finPoints[i+1] = py + math.sin((i/2) / 2 * math.pi + time * 0.5) * size * 0.02
    end
    
    love.graphics.polygon("fill", unpack(finPoints))
end

function drawWhaleDetails(x, y, size)
    local bodyWidth = size * 1.6
    local bodyHeight = size * 0.45
    
    -- Head and eye area
    local headWidth = size * 0.4
    local headHeight = size * 0.3
    local headX = x - bodyWidth * 0.7
    local headY = y - bodyHeight * 0.1
    
    -- Eye - more realistic with shading
    love.graphics.setColor(0.9, 0.9, 0.9)  -- Off-white
    local eyeX = headX + headWidth * 0.2
    local eyeY = headY - headHeight * 0.15
    local eyeSize = size * 0.035
    love.graphics.circle("fill", eyeX, eyeY, eyeSize)
    
    -- Iris and pupil
    love.graphics.setColor(0.1, 0.1, 0.3)  -- Dark blue-black
    love.graphics.circle("fill", eyeX, eyeY, eyeSize * 0.7)
    love.graphics.setColor(0, 0, 0)  -- Black pupil
    love.graphics.circle("fill", eyeX, eyeY, eyeSize * 0.4)
    
    -- Eye highlight
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", eyeX - eyeSize * 0.2, eyeY - eyeSize * 0.2, eyeSize * 0.2)
    
    -- Baleen plates (for filter feeding)
    love.graphics.setColor(0.1, 0.1, 0.15)
    for i = 1, 6 do
        local startX = headX - headWidth * 0.6 + (i-1) * headWidth * 0.15
        local startY = headY + headHeight * 0.2
        local endY = headY + headHeight * 0.5
        love.graphics.setLineWidth(1)
        love.graphics.line(startX, startY, startX, endY)
    end
    
    -- Mouth line - slight curve
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0.1, 0.1, 0.15)
    
    local mouthCurve = {}
    for i = 0, 10 do
        local t = i / 10
        local curveX = headX - headWidth * 0.8 + t * headWidth * 0.7
        local curveY = headY + headHeight * 0.3 + math.sin(t * math.pi) * headHeight * 0.1
        table.insert(mouthCurve, curveX)
        table.insert(mouthCurve, curveY)
    end
    love.graphics.line(unpack(mouthCurve))
    
    -- Blowhole - more anatomically accurate
    love.graphics.setColor(0, 0, 0, 0.7)
    local blowholeX = x - bodyWidth * 0.3
    local blowholeY = y - bodyHeight * 0.9
    love.graphics.ellipse("fill", blowholeX, blowholeY, size * 0.04, size * 0.02)
    
    -- Throat grooves (characteristic of baleen whales)
    love.graphics.setColor(whaleMainColor[1] * 0.9, whaleMainColor[2] * 0.9, whaleMainColor[3] * 0.9)
    love.graphics.setLineWidth(1)
    for i = 1, 8 do
        local startX = headX - headWidth * 0.2
        local endX = x
        local lineY = y + bodyHeight * 0.2 + i * bodyHeight * 0.05
        love.graphics.line(startX, lineY, endX, lineY)
    end
end

function drawWhaleTexture(x, y, size)
    local bodyWidth = size * 1.6
    local bodyHeight = size * 0.45
    
    -- Apply small dots and lines to simulate skin texture
    love.graphics.setColor(1, 1, 1, 0.05)  -- Very subtle white dots
    
    for _, dot in ipairs(whaleTexture) do
        local dotX = x - bodyWidth + dot.x * bodyWidth * 2
        local dotY = y - bodyHeight + dot.y * bodyHeight * 2
        
        -- Only draw dots that would be on the whale's body
        local distX = (dotX - x) / bodyWidth
        local distY = (dotY - y) / bodyHeight
        local onBody = (distX*distX + distY*distY*4) < 1
        
        if onBody then
            love.graphics.circle("fill", dotX, dotY, dot.size)
        end
    end
    
    -- Add some natural color variation
    for i = 1, 50 do
        local spotX = x - bodyWidth + love.math.random() * bodyWidth * 2
        local spotY = y - bodyHeight + love.math.random() * bodyHeight * 2
        
        local distX = (spotX - x) / bodyWidth
        local distY = (spotY - y) / bodyHeight
        local onBody = (distX*distX + distY*distY*4) < 0.9
        
        if onBody then
            love.graphics.setColor(whaleMainColor[1] * (0.8 + love.math.random() * 0.4),
                                  whaleMainColor[2] * (0.8 + love.math.random() * 0.4),
                                  whaleMainColor[3] * (0.8 + love.math.random() * 0.4),
                                  0.3)
            local spotSize = love.math.random(5, 15)
            love.graphics.circle("fill", spotX, spotY, spotSize)
        end
    end
end

function drawBubbles(whaleX, whaleY, time)
    local bodyWidth = 200 * 1.6
    local bodyHeight = 200 * 0.45
    
    -- Draw spray from the blowhole when the whale is near the top
    local blowholeX = whaleX - bodyWidth * 0.3
    local blowholeY = whaleY - bodyHeight * 0.9
    
    -- Bubbles from the blowhole
    love.graphics.setColor(1, 1, 1, 0.7) 
    
    for i = 1, 12 do
        local offset = i * 35
        local bubbleY = blowholeY - offset - math.sin(time * 2 + i) * 8
        local bubbleX = blowholeX + math.cos(time + i) * 12
        local size = 2 + math.sin(time + i * 0.5) * 2
        
        -- Bubbles get smaller and more transparent as they rise
        local opacity = 0.7 - (offset / 350)
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.circle("fill", bubbleX, bubbleY, size)
    end
    
    -- General ocean bubbles
    love.graphics.setColor(1, 1, 1, 0.3)
    for i = 1, 30 do
        local bubbleX = love.math.random(0, love.graphics.getWidth())
        local bubbleY = love.math.random(0, love.graphics.getHeight())
        local size = love.math.random(1, 3)
        local speed = size / 2
        
        -- Move bubbles up
        bubbleY = (bubbleY - time * speed * 20) % love.graphics.getHeight()
        
        love.graphics.circle("fill", bubbleX, bubbleY, size)
    end
    
    -- Additional detailed bubbles around the whale
    love.graphics.setColor(1, 1, 1, 0.5)
    for i = 1, 15 do
        local angle = love.math.random() * math.pi * 2
        local distance = love.math.random(50, 250)
        local bubbleX = whaleX + math.cos(angle) * distance
        local bubbleY = whaleY + math.sin(angle) * distance
        local size = love.math.random(1, 4)
        
        -- Small bubble clusters
        if love.math.random() > 0.7 then
            for j = 1, love.math.random(2, 4) do
                local clusterX = bubbleX + love.math.random(-10, 10)
                local clusterY = bubbleY + love.math.random(-10, 10)
                love.graphics.circle("fill", clusterX, clusterY, size * 0.7)
            end
        else
            love.graphics.circle("fill", bubbleX, bubbleY, size)
        end
    end
end
