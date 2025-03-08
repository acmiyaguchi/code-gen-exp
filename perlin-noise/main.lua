-- Perlin Noise Terrain Generator in Love2D

-- Perlin noise implementation (simplified from a typical implementation for brevity)
local function noise(x, y, seed)
    seed = seed or 0  -- Default seed to 0 if nil
    local n = x + y * 57 + seed
    n = bit.bxor(bit.lshift(n, 13), n)
    return (1.0 - (bit.band(n * (n * n * 15731 + 789221) + 1376312589, 0x7fffffff)) / 1073741824.0)
end

local function smoothNoise(x, y, seed)
    seed = seed or 0  -- Default seed to 0 if nil
    local corners = (noise(x-1, y-1, seed) + noise(x+1, y-1, seed) + noise(x-1, y+1, seed) + noise(x+1, y+1, seed)) / 16
    local sides   = (noise(x-1, y, seed) + noise(x+1, y, seed) + noise(x, y-1, seed) + noise(x, y+1, seed)) /  8
    local center  =  noise(x, y, seed) / 4
    return corners + sides + center
end

local function interpolate(a, b, x)
    local ft = x * math.pi
    local f = (1 - math.cos(ft)) * 0.5
    return  a*(1-f) + b*f
end

local function interpolatedNoise(x, y, seed)
    seed = seed or 0  -- Default seed to 0 if nil
    local intX = math.floor(x)
    local fracX = x - intX
    local intY = math.floor(y)
    local fracY = y - intY

    local v1 = smoothNoise(intX,     intY, seed)
    local v2 = smoothNoise(intX + 1, intY, seed)
    local v3 = smoothNoise(intX,     intY + 1, seed)
    local v4 = smoothNoise(intX + 1, intY + 1, seed)

    local i1 = interpolate(v1, v2, fracX)
    local i2 = interpolate(v3, v4, fracX)

    return interpolate(i1, i2, fracY)
end



local function perlinNoise2D(x, y, octaves, persistence, scale, seed)
  seed = seed or 0 -- Default seed to 0
  local total = 0
  local frequency = 1
  local amplitude = 1
  local maxAmplitude = 0

  for i = 1, octaves do
    total = total + interpolatedNoise(x * frequency / scale, y * frequency / scale, seed) * amplitude
    maxAmplitude = maxAmplitude + amplitude
    amplitude = amplitude * persistence
    frequency = frequency * 2
  end

  return total / maxAmplitude
end


-- Game variables
local tileWidth = 20
local tileHeight = 20
local screenWidth = 800
local screenHeight = 600
local mapWidth = screenWidth / tileWidth
local mapHeight = screenHeight / tileHeight

local terrainMap = {}
local currentSeed

-- Configuration for Perlin Noise
local octaves = 4
local persistence = 0.6
local scale = 60

function generateTerrain(seed)
    currentSeed = seed or love.math.random(1, 10000)
    for x = 0, mapWidth - 1 do
        terrainMap[x] = {}
        for y = 0, mapHeight -1 do
           local noiseVal = perlinNoise2D(x, y, octaves, persistence, scale, currentSeed)

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

function love.load()
	love.window.setMode(screenWidth, screenHeight, {resizable=true})
    generateTerrain()
    love.graphics.setFont(love.graphics.newFont(16)) -- Set a default font and size
end


function love.update(dt)
    screenWidth, screenHeight = love.graphics.getDimensions()
    mapWidth = math.ceil(screenWidth / tileWidth)
    mapHeight = math.ceil(screenHeight/ tileHeight)
end

function love.draw()
    -- Draw the terrain
    for x = 0, mapWidth - 1 do
        for y = 0, mapHeight - 1 do
            local tileType = terrainMap[x] and terrainMap[x][y] or "water"

            local r, g, b = 0, 0, 0

            if tileType == "water" then
                r, g, b = 0, 0, 1
            elseif tileType == "water_shallow" then
                r, g, b = 0.2, 0.4, 0.9
            elseif tileType == "sand" then
                r, g, b = 1, 0.8, 0.4
            elseif tileType == "grass" then
                r, g, b = 0, 0.5, 0
            elseif tileType == "forest" then
              r,g,b = 0, 0.3, 0
            elseif tileType == "mountain" then
                r, g, b = 0.5, 0.5, 0.5
            end

            love.graphics.setColor(r, g, b)
            love.graphics.rectangle("fill", x * tileWidth, y * tileHeight, tileWidth, tileHeight)
        end
    end

    -- Draw debug information
    love.graphics.setColor(1, 1, 1) -- White color for text
    local debugText = string.format("Seed: %d\nZoom: %.2f\nOctaves: %d\nPersistence: %.2f\nScale: %.2f",
                                    currentSeed, tileWidth / 20, octaves, persistence, scale)
    love.graphics.print(debugText, screenWidth - 200, 10) -- Position in top-right corner
end


function love.keypressed(key)
    if key == "r" then
      generateTerrain()
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        tileWidth = math.min(tileWidth * 1.2, 120)
        tileHeight = math.min(tileHeight * 1.2, 120)
    elseif y < 0 then
      tileWidth = math.max(tileWidth / 1.2, 5)
      tileHeight = math.max(tileHeight / 1.2, 5)
    end

    mapWidth = math.ceil(screenWidth / tileWidth)
    mapHeight = math.ceil(screenHeight / tileHeight)
    generateTerrain(currentSeed)

end

function love.resize(w, h)
    screenWidth = w
    screenHeight = h
    mapWidth = math.ceil(screenWidth / tileWidth)
    mapHeight = math.ceil(screenHeight / tileHeight)
    generateTerrain(currentSeed)
end