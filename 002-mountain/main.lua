-- Mountain in 3D with Love2D - Controlled Rotation (Corrected Winding)

-- Configuration (same as previous, no changes here)
local screenWidth = 800
local screenHeight = 600
local mountainWidth = 500
local mountainHeight = 500
local mountainDepth = 400
local numPointsX = 50
local numPointsZ = 40
local terrainScale = 1.5
local rotateAmount = 0.05

-- Camera parameters
local cameraX = 0
local cameraY = mountainHeight * 0.5
local cameraZ = -mountainDepth * 0.8
local cameraRotation = 0
local cameraFOV = math.pi / 3
local cameraNearPlane = 0.1
local cameraFarPlane = 1000

-- Input state
local isRotatingLeft = false
local isRotatingRight = false
local isDragging = false
local lastMouseX = 0

-- Generate terrain data (same as previous, no changes here)
local terrain = {}
for z = 1, numPointsZ do
  terrain[z] = {}
  for x = 1, numPointsX do
    local nx = (x / numPointsX) * mountainWidth - mountainWidth / 2
    local nz = (z / numPointsZ) * mountainDepth - mountainDepth / 2
    local noise1 = love.math.noise(x * 0.03, z * 0.03) * 0.6
    local noise2 = love.math.noise(x * 0.1, z * 0.1) * 0.3
    local noise3 = love.math.noise(x * 0.3, z * 0.3) * 0.1
    local noise = noise1 + noise2 + noise3
    local height = noise * mountainHeight * terrainScale
    local edgeDistanceX = math.abs(nx) / (mountainWidth / 2)
    local edgeDistanceZ = math.abs(nz) / (mountainDepth / 2)
    local edgeFactor = 1 - (edgeDistanceX * edgeDistanceX) * (edgeDistanceZ * edgeDistanceZ)
    edgeFactor = math.max(0, edgeFactor)
    height = height * edgeFactor
    terrain[z][x] = { x = nx, y = height, z = nz }
  end
end

-- Perspective projection function (same as previous)
function project(point)
    local x = point.x - cameraX
    local y = point.y - cameraY
    local z = point.z - cameraZ
    local rotatedX = x * math.cos(cameraRotation) - z * math.sin(cameraRotation)
    local rotatedZ = x * math.sin(cameraRotation) + z * math.cos(cameraRotation)
    local f = cameraFOV / 2
    local distance = rotatedZ
    if distance <= cameraNearPlane then
        return nil, nil
    end
    local scale = 1 / math.tan(f) / distance
    local projectedX = rotatedX * scale * screenWidth + screenWidth / 2
    local projectedY = -y * scale * screenHeight + screenHeight / 2
    return projectedX, projectedY
end

function love.load()
    love.window.setMode(screenWidth, screenHeight)
    love.graphics.setBackgroundColor(0.4, 0.6, 0.8)
    love.mouse.setRelativeMode(false)
end

function love.update(dt)
    if isRotatingLeft then
        cameraRotation = cameraRotation - rotateAmount
    end
    if isRotatingRight then
        cameraRotation = cameraRotation + rotateAmount
    end

    if isDragging then
        local dx = love.mouse.getX() - lastMouseX
        cameraRotation = cameraRotation + dx * 0.01
        lastMouseX = love.mouse.getX()
    end
end

function love.draw()
    -- Draw the mountain (CORRECTED WINDING ORDER)
    for z = 1, numPointsZ - 1 do
        for x = 1, numPointsX - 1 do
            local p1 = terrain[z][x]
            local p2 = terrain[z][x + 1]
            local p3 = terrain[z + 1][x]
            local p4 = terrain[z + 1][x + 1]

            local x1, y1 = project(p1)
            local x2, y2 = project(p2)
            local x3, y3 = project(p3)
            local x4, y4 = project(p4)

            if x1 and y1 and x2 and y2 and x3 and y3 and x4 and y4 then
                local averageHeight = (p1.y + p2.y + p3.y + p4.y) / 4
                local baseColorR, baseColorG, baseColorB = 0.54, 0.27, 0.07
                local colorScale = 0.4 + (averageHeight / (mountainHeight * terrainScale)) * 0.6
                colorScale = math.min(1, math.max(0, colorScale))
                local r, g, b = baseColorR * colorScale, baseColorG * colorScale, baseColorB * colorScale
                love.graphics.setColor(r, g, b)

                -- Corrected winding order (counter-clockwise)
                love.graphics.polygon("fill", x1, y1, x3, y3, x2, y2)  -- Triangle 1
                love.graphics.polygon("fill", x2, y2, x3, y3, x4, y4)  -- Triangle 2
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Camera Rotation: " .. string.format("%.2f", cameraRotation), 10, 10)
    love.graphics.print("Hold Left/Right arrow keys or Left-click and drag to rotate", 10, 30)
end

-- Input handling (same as before)
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "left" then
        isRotatingLeft = true
    elseif key == "right" then
        isRotatingRight = true
    end
end

function love.keyreleased(key)
    if key == "left" then
        isRotatingLeft = false
    elseif key == "right" then
        isRotatingRight = false
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        isDragging = true
        lastMouseX = x
        love.mouse.setRelativeMode(true)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        isDragging = false
        love.mouse.setRelativeMode(false)
    end
end