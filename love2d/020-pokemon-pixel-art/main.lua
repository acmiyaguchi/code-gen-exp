local currentPokemon = 1
local pokemon = {"Bulbasaur", "Charmander", "Squirtle"}
local showingPokemon = true
local animationTimer = 0
local animationDuration = 0.5
local pixels = {}
local pokeballPixels = {}
local gridSizes = {16, 32, 64}
local currentGridSize = 2  -- Default to 32x32

-- Colors for each Pokemon
local colors = {
  -- Bulbasaur (greens and reds)
  {
    body = {0.2, 0.8, 0.2},
    spots = {0, 0.6, 0.1},
    bulb = {0.7, 0.2, 0.3},
    eye = {1, 0, 0},
  },
  -- Charmander (oranges and reds)
  {
    body = {1, 0.6, 0.2},
    belly = {1, 0.8, 0.4},
    flame = {1, 0.2, 0},
    eye = {0, 0, 0},
  },
  -- Squirtle (blues and creams)
  {
    body = {0.2, 0.6, 1},
    shell = {0.7, 0.5, 0.2},
    skin = {0.8, 0.8, 0.6},
    eye = {0, 0, 0},
  }
}

-- Pokeball colors
local pokeballColors = {
  top = {1, 0, 0},
  bottom = {1, 1, 1},
  button = {0.8, 0.8, 0.8},
  outline = {0, 0, 0}
}

-- Noise function (simple implementation)
local function noise(x, y, seed)
  return love.math.noise(x/10, y/10, seed)
end

-- Initialize the game
function love.load()
  love.window.setTitle("Pixel Art Pokemon Generator")
  love.window.setMode(800, 800)
  math.randomseed(os.time())
  
  -- Generate initial Pokemon and Pokeball
  generatePokeball()
  generatePokemon(currentPokemon)
end

-- Generate pokeball pixels
function generatePokeball()
  pokeballPixels = {}
  local gridSize = gridSizes[currentGridSize]
  local cellSize = 800 / gridSize
  
  for y = 1, gridSize do
    for x = 1, gridSize do
      local centerX, centerY = gridSize/2, gridSize/2
      local distFromCenter = math.sqrt((x - centerX)^2 + (y - centerY)^2)
      
      if distFromCenter < gridSize/2 - gridSize/16 then
        local color
        if y < gridSize/2 then
          color = pokeballColors.top
        else
          color = pokeballColors.bottom
        end
        
        -- Add outline
        if distFromCenter > gridSize/2 - gridSize/8 or math.abs(y - gridSize/2) < gridSize/16 then
          color = pokeballColors.outline
        end
        
        -- Add center button
        if distFromCenter < gridSize/8 then
          color = pokeballColors.button
        end
        
        table.insert(pokeballPixels, {
          x = x,
          y = y,
          size = cellSize,
          color = color
        })
      end
    end
  end
end

-- Generate Pokemon pixels based on selected type
function generatePokemon(pokemonIndex)
  pixels = {}
  local gridSize = gridSizes[currentGridSize]
  local cellSize = 800 / gridSize
  local pokemonSeed = love.math.random(1, 1000)
  
  if pokemonIndex == 1 then
    -- Generate Bulbasaur
    generateBulbasaur(gridSize, cellSize, pokemonSeed)
  elseif pokemonIndex == 2 then
    -- Generate Charmander
    generateCharmander(gridSize, cellSize, pokemonSeed)
  else
    -- Generate Squirtle
    generateSquirtle(gridSize, cellSize, pokemonSeed)
  end
end

-- Generate Bulbasaur
function generateBulbasaur(gridSize, cellSize, seed)
  local color = colors[1]
  local scale = gridSize / 16  -- Scale factor based on 16x16 grid
  
  for y = 1, gridSize do
    for x = 1, gridSize do
      -- Basic shape for Bulbasaur
      local centerX, centerY = gridSize/2, gridSize/2 + 2 * scale
      local bulbCenterX, bulbCenterY = gridSize/2, gridSize/2 - 2 * scale
      local distFromCenter = math.sqrt((x - centerX)^2 + (y - centerY)^2)
      local distFromBulb = math.sqrt((x - bulbCenterX)^2 + (y - bulbCenterY)^2)
      
      -- Body
      if distFromCenter < 3.5 * scale + noise(x/scale, y/scale, seed) * 0.5 * scale then
        local pixelColor = color.body
        
        -- Add random spots
        if noise(x*3/scale, y*3/scale, seed + 10) > 0.7 then
          pixelColor = color.spots
        end
        
        -- Add eyes
        local eyeOffsetX = 2 * scale
        local eyeOffsetY = 1 * scale
        local eyeSize = math.max(1, scale / 2)  -- Ensure eye size scales appropriately
        
        if (math.abs(x - (centerX - eyeOffsetX)) < eyeSize and
            math.abs(y - (centerY - eyeOffsetY)) < eyeSize) or 
           (math.abs(x - (centerX + eyeOffsetX)) < eyeSize and
            math.abs(y - (centerY - eyeOffsetY)) < eyeSize) then
          pixelColor = color.eye
        end
        
        table.insert(pixels, {
          x = x,
          y = y,
          size = cellSize,
          color = pixelColor
        })
      end
      
      -- Bulb on back
      if distFromBulb < 2.5 * scale + noise(x/scale, y/scale, seed + 5) * 0.3 * scale and 
         y < bulbCenterY + 2 * scale then
        table.insert(pixels, {
          x = x,
          y = y,
          size = cellSize,
          color = color.bulb
        })
      end
    end
  end
end

-- Generate Charmander
function generateCharmander(gridSize, cellSize, seed)
  local color = colors[2]
  local scale = gridSize / 16  -- Scale factor based on 16x16 grid
  
  for y = 1, gridSize do
    for x = 1, gridSize do
      -- Basic shape for Charmander
      local centerX, centerY = gridSize/2, gridSize/2 + 2 * scale
      local distFromCenter = math.sqrt((x - centerX)^2 + (y - centerY)^2)
      
      -- Body
      if distFromCenter < 3 * scale + noise(x/scale, y/scale, seed) * 0.5 * scale then
        local pixelColor = color.body
        
        -- Add belly
        if x > centerX - 2 * scale and x < centerX + 2 * scale and y > centerY - 1 * scale then
          pixelColor = color.belly
        end
        
        -- Add eyes
        local eyeOffsetX = 1.5 * scale
        local eyeOffsetY = 2 * scale
        local eyeSize = math.max(1, scale / 2)
        
        if (math.abs(x - (centerX - eyeOffsetX)) < eyeSize and
            math.abs(y - (centerY - eyeOffsetY)) < eyeSize) or 
           (math.abs(x - (centerX + eyeOffsetX)) < eyeSize and
            math.abs(y - (centerY - eyeOffsetY)) < eyeSize) then
          pixelColor = color.eye
        end
        
        table.insert(pixels, {
          x = x,
          y = y,
          size = cellSize,
          color = pixelColor
        })
      end
      
      -- Flame on tail
      local tailX, tailY = centerX + 4 * scale, centerY
      local distFromTail = math.sqrt((x - tailX)^2 + (y - tailY)^2)
      if distFromTail < 1.5 * scale + noise(x/scale, y/scale, seed + 15) * 0.8 * scale then
        table.insert(pixels, {
          x = x,
          y = y,
          size = cellSize,
          color = color.flame
        })
      end
    end
  end
end

-- Generate Squirtle
function generateSquirtle(gridSize, cellSize, seed)
  local color = colors[3]
  local scale = gridSize / 16  -- Scale factor based on 16x16 grid
  
  for y = 1, gridSize do
    for x = 1, gridSize do
      -- Basic shape for Squirtle
      local centerX, centerY = gridSize/2, gridSize/2 + 2 * scale
      local shellCenterX, shellCenterY = gridSize/2, gridSize/2 + 3 * scale  -- Move shell more to the back
      local distFromCenter = math.sqrt((x - centerX)^2 + (y - centerY)^2)
      local distFromShell = math.sqrt((x - shellCenterX)^2 + (y - shellCenterY)^2)
      
      -- First render the body (blue parts)
      if distFromCenter < 3 * scale + noise(x/scale, y/scale, seed) * 0.4 * scale then
        local pixelColor = color.body
        
        -- Add face/belly (lighter color)
        if (x > centerX - 2 * scale and x < centerX + 2 * scale and 
            y > centerY - 3 * scale and y < centerY + 0.5 * scale) or
           (y < centerY - 1 * scale) then
          pixelColor = color.skin
        end
        
        -- Only add body pixels where the shell isn't (better shell/body relationship)
        local isShell = (distFromShell < 2.8 * scale + noise(x/scale, y/scale, seed + 7) * 0.3 * scale and 
                       y > shellCenterY - 3 * scale and 
                       y < shellCenterY + 2 * scale and
                       math.abs(x - shellCenterX) < 3 * scale)
        
        if not isShell then
          table.insert(pixels, {
            x = x,
            y = y,
            size = cellSize,
            color = pixelColor
          })
        end
      end
      
      -- Add shell (drawn after body so it appears on top)
      if distFromShell < 2.8 * scale + noise(x/scale, y/scale, seed + 7) * 0.3 * scale and 
         y > shellCenterY - 3 * scale and 
         y < shellCenterY + 2 * scale and
         math.abs(x - shellCenterX) < 3 * scale then
        
        local shellColor = color.shell
        
        -- Add shell pattern
        if noise(x*2/scale, y*2/scale, seed + 20) > 0.7 then
          -- Shell patterns
          shellColor = {shellColor[1] * 0.8, shellColor[2] * 0.8, shellColor[3] * 0.8}
        end
        
        table.insert(pixels, {
          x = x,
          y = y,
          size = cellSize,
          color = shellColor
        })
      end
      
      -- Add eyes (on top of everything)
      local eyeOffsetX = 1.5 * scale
      local eyeOffsetY = 2 * scale
      local eyeSize = math.max(1, scale / 2)
      
      if (math.abs(x - (centerX - eyeOffsetX)) < eyeSize and
          math.abs(y - (centerY - eyeOffsetY)) < eyeSize) or 
         (math.abs(x - (centerX + eyeOffsetX)) < eyeSize and
          math.abs(y - (centerY - eyeOffsetY)) < eyeSize) then
        table.insert(pixels, {
          x = x,
          y = y,
          size = cellSize,
          color = color.eye
        })
      end
    end
  end
end

-- Handle keyboard input
function love.keypressed(key)
  if key == "right" or key == "d" then
    currentPokemon = (currentPokemon % 3) + 1
    showingPokemon = true
    animationTimer = 0
    generatePokemon(currentPokemon)
  elseif key == "left" or key == "a" then
    currentPokemon = ((currentPokemon - 2) % 3) + 1
    showingPokemon = true
    animationTimer = 0
    generatePokemon(currentPokemon)
  elseif key == "space" then
    generatePokemon(currentPokemon)
  elseif key == "return" or key == "p" then
    showingPokemon = not showingPokemon
    animationTimer = 0
  elseif key == "up" or key == "w" then
    -- Increase grid size
    currentGridSize = math.min(currentGridSize + 1, #gridSizes)
    generatePokeball()
    generatePokemon(currentPokemon)
  elseif key == "down" or key == "s" then
    -- Decrease grid size
    currentGridSize = math.max(currentGridSize - 1, 1)
    generatePokeball()
    generatePokemon(currentPokemon)
  end
end

-- Handle mouse input
function love.mousepressed(x, y, button)
  if button == 1 then
    showingPokemon = not showingPokemon
    animationTimer = 0
  end
end

-- Update function
function love.update(dt)
  animationTimer = math.min(animationTimer + dt, animationDuration)
end

-- Draw function
function love.draw()
  love.graphics.setBackgroundColor(0.9, 0.9, 0.9)
  
  -- Calculate animation progress
  local progress = animationTimer / animationDuration
  local scale = 1
  local rotation = 0
  
  if showingPokemon then
    -- Pokeball opening animation
    if progress < 1 then
      -- Draw pokeball first, scaling down
      local pokeballScale = 1 - progress
      drawPixels(pokeballPixels, 400, 400, pokeballScale, progress * math.pi)
      
      -- Draw pokemon scaling up
      local pokemonScale = progress
      drawPixels(pixels, 400, 400, pokemonScale, 0)
    else
      -- Just draw pokemon
      drawPixels(pixels, 400, 400, 1, 0)
    end
  else
    -- Pokemon returning animation
    if progress < 1 then
      -- Draw pokemon first, scaling down
      local pokemonScale = 1 - progress
      drawPixels(pixels, 400, 400, pokemonScale, 0)
      
      -- Draw pokeball scaling up
      local pokeballScale = progress
      drawPixels(pokeballPixels, 400, 400, pokeballScale, progress * math.pi)
    else
      -- Just draw pokeball
      drawPixels(pokeballPixels, 400, 400, 1, 0)
    end
  end
  
  -- Draw UI
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("Current Pokemon: " .. pokemon[currentPokemon], 20, 20)
  love.graphics.print("Resolution: " .. gridSizes[currentGridSize] .. "x" .. gridSizes[currentGridSize], 20, 40)
  love.graphics.print("Controls:", 20, 720)
  love.graphics.print("Left/Right or A/D: Cycle Pokemon", 20, 740)
  love.graphics.print("Up/Down or W/S: Change resolution", 20, 760)
  love.graphics.print("Space: Regenerate current Pokemon", 20, 780)
  love.graphics.print("Enter/P or Mouse Click: Toggle Pokeball", 20, 800)
end

-- Helper function to draw pixel arrays
function drawPixels(pixelArray, centerX, centerY, scale, rotation)
  love.graphics.push()
  love.graphics.translate(centerX, centerY)
  love.graphics.rotate(rotation)
  love.graphics.scale(scale, scale)
  love.graphics.translate(-400, -400)
  
  for _, pixel in ipairs(pixelArray) do
    love.graphics.setColor(pixel.color)
    love.graphics.rectangle("fill", 
      (pixel.x - 0.5) * pixel.size, 
      (pixel.y - 0.5) * pixel.size, 
      pixel.size, 
      pixel.size)
  end
  
  love.graphics.pop()
end