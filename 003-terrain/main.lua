-- Configuration
local tileWidth = 32
local tileHeight = 16
local mapWidth = 20
local mapHeight = 20
local heightScale = 8

-- Camera controls
local cameraX = 0
local cameraY = 0
local cameraSpeed = 200  -- Pixels per second

-- Colors
local colors = {
  water = {0, 0, 128},
  grass = {34, 139, 34},
  dirt = {139, 69, 19},
  rock = {169, 169, 169},
  snow = {255, 255, 255}
}

-- Pre-defined Heightmap
local heightmap = {}
for x = 1, mapWidth do
  heightmap[x] = {}
  for y = 1, mapHeight do
    local height = math.floor(math.sin(x / 4) * 1.5 + math.cos(y / 3) * 1.5 + 2)
    height = math.max(0, math.min(height, 4))
    heightmap[x][y] = height
  end
end

function love.load()
    -- Center the camera initially.
    cameraX = love.graphics.getWidth() / 2 - (mapWidth * tileWidth) / 4
    cameraY = 0
end

function love.update(dt)
    -- Camera movement controls (CORRECTED)
    if love.keyboard.isDown("right") then
        cameraX = cameraX - cameraSpeed * dt  -- Move camera left when pressing right
    end
    if love.keyboard.isDown("left") then
        cameraX = cameraX + cameraSpeed * dt  -- Move camera right when pressing left
    end
    if love.keyboard.isDown("down") then
        cameraY = cameraY - cameraSpeed * dt  -- Move camera up when pressing down
    end
    if love.keyboard.isDown("up") then
        cameraY = cameraY + cameraSpeed * dt  -- Move camera down when pressing up
    end
end

function drawTile(x, y, height)
    local screenX = (x - y) * tileWidth / 2 + cameraX
    local screenY = (x + y) * tileHeight / 2 - height * heightScale + cameraY

    --  Clipping (optimization): Only draw tiles that are on screen.
    if screenX + tileWidth > 0 and screenX < love.graphics.getWidth() and
       screenY + tileHeight > 0 and screenY < love.graphics.getHeight() then
        local color
        if height == 0 then
            color = colors.water
        elseif height == 1 then
            color = colors.grass
        elseif height == 2 then
            color = colors.dirt
        elseif height == 3 then
            color = colors.rock
        else
            color = colors.snow
        end
        love.graphics.setColor(color)
        love.graphics.polygon('fill',
            screenX, screenY,
            screenX + tileWidth / 2, screenY + tileHeight / 2,
            screenX, screenY + tileHeight,
            screenX - tileWidth / 2, screenY + tileHeight / 2
        )
    end
end


function love.draw()
  love.graphics.setBackgroundColor(0.7, 0.8, 1)

  -- Draw tiles with correct layering
  for layer = 2, mapWidth + mapHeight do
    for x = 1, mapWidth do
      for y = 1, mapHeight do
        if x + y == layer then
          drawTile(x, y, heightmap[x][y])
        end
      end
    end
  end
  
    -- Optional: Display camera coordinates for debugging
  love.graphics.setColor(255,255,255) --white
  love.graphics.print("Camera X: " .. string.format("%.2f", cameraX), 10, 10)
  love.graphics.print("Camera Y: " .. string.format("%.2f", cameraY), 10, 30)
end