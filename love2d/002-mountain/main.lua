--[[
# 3D Mountain Visualization in Love2D

This program renders a 3D mountain terrain using Love2D's 2D graphics capabilities.
It demonstrates how to implement basic 3D projection and rendering techniques
without using a dedicated 3D engine.

## Program Structure
1. Configuration variables
2. Camera system
3. Terrain generation
4. 3D projection functions
5. Rendering with depth sorting
6. User interaction handling

--]]

--[[
## 1. CONFIGURATION

These variables control the dimensions and appearance of our world.
Modifying these values allows for different terrain sizes and detail levels.
--]]

-- Screen dimensions
local screenWidth = 800
local screenHeight = 600

-- Terrain dimensions and detail
local terrainWidth = 800   -- Width of the terrain in 3D units
local terrainHeight = 600  -- Maximum height of the terrain
local terrainDepth = 800   -- Depth of the terrain in 3D units
local numPointsX = 80      -- Number of grid points along X axis
local numPointsZ = 80      -- Number of grid points along Z axis
local terrainScale = 1.5   -- Height multiplier for the terrain

-- Camera settings
local cameraDistance = 1200    -- Distance from center to camera
local cameraHeight = 300       -- Height of camera from ground
local cameraFOV = math.pi / 3  -- Field of view (60 degrees)
local cameraNearPlane = 0.1    -- Nearest visible distance
local cameraFarPlane = 2000    -- Farthest visible distance

-- Camera position (fixed)
local cameraX = 0
local cameraY = cameraHeight
local cameraZ = -cameraDistance

-- World rotation (instead of camera rotation)
local worldRotationY = 0

-- Control settings
local rotateAmount = 0.05  -- Speed of rotation
local zoomSpeed = 50       -- Speed of zooming
local minZoomDistance = 600  -- Minimum zoom distance
local maxZoomDistance = 1800 -- Maximum zoom distance

--[[
## 2. INPUT STATE TRACKING

These variables track the current state of user input.
--]]
local isRotatingLeft = false   -- Is left arrow key pressed?
local isRotatingRight = false  -- Is right arrow key pressed?
local isDragging = false       -- Is the mouse being dragged?
local lastMouseX = 0           -- Last mouse X position for drag calculation
local isZoomingIn = false      -- Is zoom in key pressed?
local isZoomingOut = false     -- Is zoom out key pressed?

--[[
## 3. TERRAIN GENERATION

We generate a heightmap using multiple octaves of Perlin noise.
The terrain features one dominant mountain peak in the center
with several smaller peaks scattered around.
--]]

local terrain = {}

local function generateTerrain()
    -- Set random seed for consistent terrain between runs
    love.math.setRandomSeed(12345)
    
    -- Calculate center of the terrain grid
    local centerX = numPointsX / 2
    local centerZ = numPointsZ / 2
    
    -- Set height of main peak
    local mainPeakHeight = terrainHeight * 1.2
    
    -- Iterate through each point on our grid
    for z = 1, numPointsZ do
        terrain[z] = {}
        for x = 1, numPointsX do
            -- Convert grid coordinates to world coordinates
            local nx = (x / numPointsX) * terrainWidth - terrainWidth / 2
            local nz = (z / numPointsZ) * terrainDepth - terrainDepth / 2
            
            -- Generate base noise for natural terrain variation
            -- We use multiple octaves of noise at different scales
            local noise1 = love.math.noise(nx * 0.002, nz * 0.002) * 0.6  -- Large features
            local noise2 = love.math.noise(nx * 0.005, nz * 0.005) * 0.3  -- Medium features
            local noise3 = love.math.noise(nx * 0.01, nz * 0.01) * 0.1    -- Small details
            local baseNoise = noise1 + noise2 + noise3
            
            -- Calculate distance from terrain center for main mountain
            local dx = x - centerX
            local dz = z - centerZ
            local distanceFromCenter = math.sqrt(dx * dx + dz * dz)
            local maxDistance = math.sqrt(centerX * centerX + centerZ * centerZ)
            
            -- Create central mountain with exponential falloff
            local mainMountainFactor = math.max(0, 1 - (distanceFromCenter / (maxDistance * 0.6)))
            mainMountainFactor = mainMountainFactor * mainMountainFactor  -- Square for steeper falloff
            
            -- Create several smaller mountains at random locations
            local smallMountains = 0
            for i = 1, 5 do  -- Add 5 smaller mountains
                -- Pick a random location for this small mountain
                local mx = love.math.random(1, numPointsX)
                local mz = love.math.random(1, numPointsZ)
                
                -- Calculate distance from this point to the mountain center
                local mdx = x - mx
                local mdz = z - mz
                local mdist = math.sqrt(mdx * mdx + mdz * mdz)
                
                -- Randomize the height of this small mountain
                local mheight = love.math.random(30, 80) / 100
                
                -- Add this mountain's height contribution based on distance
                smallMountains = smallMountains + 
                                 math.max(0, 1 - (mdist / (maxDistance * 0.15))) * 
                                 mheight * terrainHeight
            end
            
            -- Combine all height factors
            local heightValue = (mainMountainFactor * mainPeakHeight) + 
                               (smallMountains * 0.5) + 
                               (baseNoise * terrainHeight * 0.3)
            
            -- Ensure minimum height for flat ground
            heightValue = math.max(0, heightValue)
            
            -- Store the terrain point
            terrain[z][x] = { x = nx, y = heightValue, z = nz }
        end
    end
end

--[[
## 4. 3D PROJECTION

This function projects 3D points onto our 2D screen using perspective projection.
It rotates the world instead of the camera, creating an orbiting effect.
--]]

function project(point)
    -- Apply world rotation to the point (rotate around Y axis)
    local worldX = point.x * math.cos(worldRotationY) - point.z * math.sin(worldRotationY)
    local worldZ = point.x * math.sin(worldRotationY) + point.z * math.cos(worldRotationY)
    local worldY = point.y
    
    -- Translate point relative to camera position
    local x = worldX - cameraX
    local y = worldY - cameraY
    local z = worldZ - cameraZ
    
    -- Basic culling - don't render points too close to camera
    local distance = math.sqrt(x*x + z*z)
    if distance <= cameraNearPlane then
        return nil, nil
    end
    
    -- Only render what's in front of the camera
    if z <= cameraNearPlane then
        return nil, nil
    end
    
    -- Apply perspective projection
    local f = cameraFOV / 2  -- Half of the field of view
    local scale = 1 / math.tan(f) / z
    
    -- Calculate screen coordinates
    local projectedX = x * scale * screenWidth + screenWidth / 2
    local projectedY = -y * scale * screenHeight + screenHeight / 2
    
    return projectedX, projectedY
end

--[[
## 5. TERRAIN COLORING

This function determines the color of terrain based on its height.
- Ground level: Green (grass)
- Lower slopes: Green-brown mix
- Mid-mountain: Brown
- Peaks: White (snow-capped)
--]]

function getTerrainColor(height, maxHeight)
    local heightRatio = height / maxHeight
    
    if heightRatio < 0.05 then
        -- Ground level - green grass
        return 0.2, 0.6, 0.2
    elseif heightRatio < 0.4 then
        -- Lower mountain slopes - gradient from green to brown
        local mix = (heightRatio - 0.05) / 0.35
        return 0.2 + 0.34 * mix,  -- Red component: 0.2 to 0.54
               0.6 - 0.33 * mix,  -- Green component: 0.6 to 0.27
               0.2 - 0.13 * mix   -- Blue component: 0.2 to 0.07
    elseif heightRatio < 0.75 then
        -- Mid-high mountain - brown
        return 0.54, 0.27, 0.07
    else
        -- Mountain peaks - gradient from brown to white (snow)
        local mix = (heightRatio - 0.75) / 0.25
        return 0.54 + 0.46 * mix,  -- Red component: 0.54 to 1.0
               0.27 + 0.73 * mix,  -- Green component: 0.27 to 1.0
               0.07 + 0.93 * mix   -- Blue component: 0.07 to 1.0
    end
end

--[[
## 6. LOVE2D CALLBACK FUNCTIONS

These functions are called by the Love2D framework at specific moments.
--]]

-- Called once at the start of the program
function love.load()
    -- Set up the window
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("3D Mountain Range - Rotate and Zoom")
    
    -- Set blue sky background
    love.graphics.setBackgroundColor(0.5, 0.7, 0.9)
    
    -- Generate our terrain
    generateTerrain()
end

-- Called every frame to update logic
function love.update(dt)
    -- Handle keyboard rotation
    if isRotatingLeft then
        worldRotationY = worldRotationY - rotateAmount
    end
    if isRotatingRight then
        worldRotationY = worldRotationY + rotateAmount
    end

    -- Handle mouse drag rotation
    if isDragging then
        local dx = love.mouse.getX() - lastMouseX
        worldRotationY = worldRotationY + dx * 0.01
        lastMouseX = love.mouse.getX()
    end
    
    -- Handle zooming
    if isZoomingIn then
        cameraZ = cameraZ + zoomSpeed
        if cameraZ > -minZoomDistance then
            cameraZ = -minZoomDistance
        end
    end
    if isZoomingOut then
        cameraZ = cameraZ - zoomSpeed
        if cameraZ < -maxZoomDistance then
            cameraZ = -maxZoomDistance
        end
    end
end

-- Called every frame to render graphics
function love.draw()
    -- Draw sky background
    love.graphics.setColor(0.5, 0.7, 0.9)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    
    -- Prepare a table for all triangles with depth information
    local triangles = {}
    
    -- Generate triangles for rendering with proper depth info
    for z = 1, numPointsZ - 1 do
        for x = 1, numPointsX - 1 do
            -- Get the four corners of this grid cell
            local p1 = terrain[z][x]         -- Top-left
            local p2 = terrain[z][x + 1]     -- Top-right
            local p3 = terrain[z + 1][x]     -- Bottom-left
            local p4 = terrain[z + 1][x + 1] -- Bottom-right

            -- Project these points to screen space
            local x1, y1 = project(p1)
            local x2, y2 = project(p2)
            local x3, y3 = project(p3)
            local x4, y4 = project(p4)

            -- First triangle (top-left, bottom-left, top-right)
            if x1 and y1 and x2 and y2 and x3 and y3 then
                -- Calculate average height and position for coloring and depth
                local avgHeight = (p1.y + p2.y + p3.y) / 3
                
                -- Apply world rotation to get correct depth
                local avgX = (p1.x + p2.x + p3.x) / 3
                local avgZ = (p1.z + p2.z + p3.z) / 3
                local rotatedAvgX = avgX * math.cos(worldRotationY) - avgZ * math.sin(worldRotationY)
                local rotatedAvgZ = avgX * math.sin(worldRotationY) + avgZ * math.cos(worldRotationY)
                
                -- Calculate distance from camera for depth sorting
                local distToCamera = math.sqrt((rotatedAvgX - cameraX)^2 + (rotatedAvgZ - cameraZ)^2)
                
                -- Get terrain color based on height
                local r, g, b = getTerrainColor(avgHeight, terrainHeight * 1.2)
                
                -- Add triangle to our render list
                table.insert(triangles, {
                    depth = distToCamera,
                    vertices = {x1, y1, x3, y3, x2, y2},
                    color = {r, g, b}
                })
            end

            -- Second triangle (top-right, bottom-left, bottom-right)
            if x2 and y2 and x3 and y3 and x4 and y4 then
                -- Calculate average height and position for coloring and depth
                local avgHeight = (p2.y + p3.y + p4.y) / 3
                
                -- Apply world rotation to get correct depth
                local avgX = (p2.x + p3.x + p4.x) / 3
                local avgZ = (p2.z + p3.z + p4.z) / 3
                local rotatedAvgX = avgX * math.cos(worldRotationY) - avgZ * math.sin(worldRotationY)
                local rotatedAvgZ = avgX * math.sin(worldRotationY) + avgZ * math.cos(worldRotationY)
                
                -- Calculate distance from camera for depth sorting
                local distToCamera = math.sqrt((rotatedAvgX - cameraX)^2 + (rotatedAvgZ - cameraZ)^2)
                
                -- Get terrain color based on height
                local r, g, b = getTerrainColor(avgHeight, terrainHeight * 1.2)
                
                -- Add triangle to our render list
                table.insert(triangles, {
                    depth = distToCamera,
                    vertices = {x2, y2, x3, y3, x4, y4},
                    color = {r, g, b}
                })
            end
        end
    end

    -- Sort triangles back-to-front (painter's algorithm)
    table.sort(triangles, function(a, b) return a.depth > b.depth end)

    -- Draw all triangles in sorted order
    for _, triangle in ipairs(triangles) do
        -- Fill with the terrain color
        love.graphics.setColor(triangle.color)
        love.graphics.polygon("fill", triangle.vertices)
        
        -- Draw a subtle outline
        love.graphics.setColor(0, 0, 0, 0.1)
        love.graphics.polygon("line", triangle.vertices)
    end

    -- Draw UI text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Left/Right: rotate | Up/Down: zoom | Click and drag to rotate", 10, 10)
    love.graphics.print("Rotation: " .. string.format("%.2f", worldRotationY) .. 
                      " | Zoom: " .. string.format("%.0f", -cameraZ), 10, 30)
end

--[[
## 7. INPUT HANDLING

These functions handle user input for rotation and zooming.
--]]

-- Called when a key is pressed
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()  -- Exit the program
    elseif key == "left" then
        isRotatingLeft = true
    elseif key == "right" then
        isRotatingRight = true
    elseif key == "up" then
        isZoomingIn = true
    elseif key == "down" then
        isZoomingOut = true
    end
end

-- Called when a key is released
function love.keyreleased(key)
    if key == "left" then
        isRotatingLeft = false
    elseif key == "right" then
        isRotatingRight = false
    elseif key == "up" then
        isZoomingIn = false
    elseif key == "down" then
        isZoomingOut = false
    end
end

-- Called when a mouse button is pressed
function love.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        isDragging = true
        lastMouseX = x
    end
end

-- Called when a mouse button is released
function love.mousereleased(x, y, button)
    if button == 1 then
        isDragging = false
    end
end

-- Handle mouse wheel for zooming
function love.wheelmoved(x, y)
    if y > 0 then  -- Scroll up
        cameraZ = cameraZ + zoomSpeed * 3
        if cameraZ > -minZoomDistance then
            cameraZ = -minZoomDistance
        end
    elseif y < 0 then  -- Scroll down
        cameraZ = cameraZ - zoomSpeed * 3
        if cameraZ < -maxZoomDistance then
            cameraZ = -maxZoomDistance
        end
    end
end