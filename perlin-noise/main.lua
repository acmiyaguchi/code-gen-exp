-- Perlin Noise Terrain Generator in Love2D

-- Perlin noise implementation (simplified from a typical implementation for brevity)
local function noise(x, y)
    local n = x + y * 57
    n = bit.bxor(bit.lshift(n, 13), n)
    return (1.0 - (bit.band(n * (n * n * 15731 + 789221) + 1376312589, 0x7fffffff)) / 1073741824.0)
end

local function smoothNoise(x, y)
    local corners = (noise(x-1, y-1) + noise(x+1, y-1) + noise(x-1, y+1) + noise(x+1, y+1)) / 16
    local sides   = (noise(x-1, y) + noise(x+1, y) + noise(x, y-1) + noise(x, y+1)) /  8
    local center  =  noise(x, y) / 4
    return corners + sides + center
end

local function interpolate(a, b, x)
    local ft = x * math.pi
    local f = (1 - math.cos(ft)) * 0.5
    return  a*(1-f) + b*f
end

local function interpolatedNoise(x, y)
    local intX = math.floor(x)
    local fracX = x - intX
    local intY = math.floor(y)
    local fracY = y - intY

    local v1 = smoothNoise(intX,     intY)
    local v2 = smoothNoise(intX + 1, intY)
    local v3 = smoothNoise(intX,     intY + 1)
    local v4 = smoothNoise(intX + 1, intY + 1)

    local i1 = interpolate(v1, v2, fracX)
    local i2 = interpolate(v3, v4, fracX)

    return interpolate(i1, i2, fracY)
end



local function perlinNoise2D(x, y, octaves, persistence, scale)
  local total = 0
  local frequency = 1
  local amplitude = 1
  local maxAmplitude = 0  -- Keep track of the maximum possible amplitude

  for i = 1, octaves do
    total = total + interpolatedNoise(x * frequency / scale, y * frequency / scale) * amplitude
    maxAmplitude = maxAmplitude + amplitude
    amplitude = amplitude * persistence
    frequency = frequency * 2
  end

  return total / maxAmplitude  -- Normalize to the range [-1, 1]
end


-- Game variables
local tileWidth = 20
local tileHeight = 20
local screenWidth = 800
local screenHeight = 600
local mapWidth = screenWidth / tileWidth
local mapHeight = screenHeight / tileHeight

local terrainMap = {}

-- Configuration for Perlin Noise
local octaves = 4
local persistence = 0.6
local scale = 60 -- Smaller scale = larger features, larger scale = smaller features.


function love.load()
    -- Generate the terrain map
    for x = 0, mapWidth - 1 do
        terrainMap[x] = {}
        for y = 0, mapHeight -1 do
           local noiseVal = perlinNoise2D(x, y, octaves, persistence, scale)

            -- Basic thresholding for terrain types:
            if noiseVal < -0.2 then
                terrainMap[x][y] = "water"  -- Deep water
            elseif noiseVal < 0 then
                terrainMap[x][y] = "water_shallow" --shallow water
            elseif noiseVal < 0.1 then
                terrainMap[x][y] = "sand"   -- Beach
            elseif noiseVal < 0.6 then
                terrainMap[x][y] = "grass"  -- Grassland
            elseif noiseVal < 0.8 then
              terrainMap[x][y] = "forest"  --forest
            else
                terrainMap[x][y] = "mountain" -- Mountain
            end
        end
    end
	love.window.setMode(screenWidth, screenHeight, {resizable=true})
end

function love.update(dt)
    -- Handle window resizing (optional but good practice)
    screenWidth, screenHeight = love.graphics.getDimensions()
    mapWidth = math.ceil(screenWidth / tileWidth)
    mapHeight = math.ceil(screenHeight/ tileHeight)


end



function love.draw()
    for x = 0, mapWidth - 1 do
        for y = 0, mapHeight - 1 do
            local tileType = terrainMap[x] and terrainMap[x][y] or "water"  -- Default to water if out of bounds

            -- Choose color based on terrain type
            local r, g, b = 0, 0, 0

            if tileType == "water" then
                r, g, b = 0, 0, 1  -- Blue
            elseif tileType == "water_shallow" then
                r, g, b = 0.2, 0.4, 0.9
            elseif tileType == "sand" then
                r, g, b = 1, 0.8, 0.4 -- Yellowish
            elseif tileType == "grass" then
                r, g, b = 0, 0.5, 0  -- Green
            elseif tileType == "forest" then
              r,g,b = 0, 0.3, 0
            elseif tileType == "mountain" then
                r, g, b = 0.5, 0.5, 0.5 -- Gray
            end

            love.graphics.setColor(r, g, b)
            love.graphics.rectangle("fill", x * tileWidth, y * tileHeight, tileWidth, tileHeight)
        end
    end
end


function love.keypressed(key)
    if key == "r" then
      love.load() --regenerates map on keypress
    end
end

function love.wheelmoved(x, y)
    if y > 0 then --zoom in
        tileWidth = math.min(tileWidth * 1.2, 120)  -- Limit maximum zoom
        tileHeight = math.min(tileHeight * 1.2, 120)
    elseif y < 0 then --zoom out
      tileWidth = math.max(tileWidth / 1.2, 5)  -- Limit minimum zoom
      tileHeight = math.max(tileHeight / 1.2, 5)
    end

      -- Recalculate map dimensions based on new tile size
    mapWidth = math.ceil(screenWidth / tileWidth)
    mapHeight = math.ceil(screenHeight / tileHeight)


    -- Regenerate visible portion of terrain (very basic, no scrolling)
     for x = 0, mapWidth - 1 do
        terrainMap[x] = terrainMap[x] or {}  -- Make sure the column exists
        for y = 0, mapHeight -1 do
           local noiseVal = perlinNoise2D(x, y, octaves, persistence, scale)
            -- Basic thresholding (same as love.load)
            if noiseVal < -0.2 then
                terrainMap[x][y] = "water"
            elseif noiseVal < 0 then
                terrainMap[x][y] = "water_shallow"
            elseif noiseVal < 0.1 then
                terrainMap[x][y] = "sand"
            elseif noiseVal < 0.6 then
                terrainMap[x][y] = "grass"
            elseif noiseVal < 0.8 then
              terrainMap[x][y] = "forest"
            else
                terrainMap[x][y] = "mountain"
            end
        end
    end
end

function love.resize(w, h)
    screenWidth = w
    screenHeight = h
    mapWidth = math.ceil(screenWidth / tileWidth)
    mapHeight = math.ceil(screenHeight / tileHeight)
      --regenerate map if you resize
    for x = 0, mapWidth - 1 do
        terrainMap[x] = terrainMap[x] or {}  -- Make sure the column exists
        for y = 0, mapHeight -1 do
           local noiseVal = perlinNoise2D(x, y, octaves, persistence, scale)
            -- Basic thresholding (same as love.load)
            if noiseVal < -0.2 then
                terrainMap[x][y] = "water"
            elseif noiseVal < 0 then
                terrainMap[x][y] = "water_shallow"
            elseif noiseVal < 0.1 then
                terrainMap[x][y] = "sand"
            elseif noiseVal < 0.6 then
                terrainMap[x][y] = "grass"
            elseif noiseVal < 0.8 then
              terrainMap[x][y] = "forest"
            else
                terrainMap[x][y] = "mountain"
            end
        end
    end
end