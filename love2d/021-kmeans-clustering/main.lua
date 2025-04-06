-- K-means Clustering Visualization
-- Interactive 2D data visualization with K-means clustering

-- Configuration
local config = {
  width = 800,
  height = 600,
  padding = 50,
  pointRadius = 3,
  centerRadius = 8,
  minK = 2,
  maxK = 10,
  defaultK = 4,
  defaultGaussians = 5,
  defaultPointsPerGaussian = 100,
  maxIterations = 100,
  buttonWidth = 120,
  buttonHeight = 25,
  sliderWidth = 150,
  sliderHeight = 15,
  sliderKnobSize = 10,
  uiPadding = 10,
  uiOpacity = 0.7
}

-- State variables
local points = {}        -- array of {x, y} coordinates
local clusterCenters = {} -- array of {x, y, color} for each center
local assignments = {}   -- point index -> cluster index
local gaussianCenters = {} -- centers for the gaussian distributions
local k = config.defaultK -- number of clusters
local converged = false
local iterations = 0
local numGaussians = config.defaultGaussians -- number of gaussian clusters
local pointsPerGaussian = config.defaultPointsPerGaussian -- points per gaussian
local showVoronoi = true
local uiState = {
  regenerateButton = {x = config.width - config.buttonWidth - config.uiPadding, y = config.uiPadding, 
                      width = config.buttonWidth, height = config.buttonHeight, text = "Regenerate Data"},
  resetKMeansButton = {x = config.width - config.buttonWidth - config.uiPadding, y = config.uiPadding*2 + config.buttonHeight, 
                       width = config.buttonWidth, height = config.buttonHeight, text = "Reset K-means"},
  voronoiButton = {x = config.width - config.buttonWidth - config.uiPadding, y = config.uiPadding*3 + config.buttonHeight*2, 
                   width = config.buttonWidth, height = config.buttonHeight, text = "Toggle Voronoi"},
  kSlider = {x = config.width - config.sliderWidth - config.uiPadding, y = config.uiPadding*4 + config.buttonHeight*3, 
             width = config.sliderWidth, height = config.sliderHeight, 
             value = config.defaultK, min = config.minK, max = config.maxK, text = "K-means clusters:"},
  gaussianSlider = {x = config.width - config.sliderWidth - config.uiPadding, y = config.uiPadding*5 + config.buttonHeight*3 + config.sliderHeight, 
                    width = config.sliderWidth, height = config.sliderHeight, 
                    value = config.defaultGaussians, min = 2, max = 10, text = "Gaussian clusters:"},
  pointsSlider = {x = config.width - config.sliderWidth - config.uiPadding, y = config.uiPadding*6 + config.buttonHeight*3 + config.sliderHeight*2, 
                  width = config.sliderWidth, height = config.sliderHeight, 
                  value = config.defaultPointsPerGaussian, min = 20, max = 200, text = "Points per cluster:"}
}

-- Colors
local colors = {
  {1, 0, 0}, {0, 1, 0}, {0, 0, 1}, {1, 1, 0}, {1, 0, 1}, {0, 1, 1}, 
  {0.5, 0, 0}, {0, 0.5, 0}, {0, 0, 0.5}, {0.5, 0.5, 0}
}

-- Helper functions
local function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local function randomGaussian(mean, stddev)
  -- Box-Muller transform for Gaussian random numbers
  local u1, u2
  repeat
    u1 = love.math.random()
  until u1 > 0
  u2 = love.math.random()
  
  local z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
  return mean + z * stddev
end

-- Function declarations
local initializeKMeans
local assignPointsToClusters

local function generateGaussianClusters()
  points = {}
  gaussianCenters = {}
  
  -- Use configured number of gaussians and points
  for i = 1, numGaussians do
    local center = {
      x = love.math.random(config.padding, config.width - config.padding),
      y = love.math.random(config.padding, config.height - config.padding),
      stddev = love.math.random(20, 50)
    }
    gaussianCenters[i] = center
    
    -- Generate points for this cluster
    for j = 1, pointsPerGaussian do
      local point = {
        x = randomGaussian(center.x, center.stddev),
        y = randomGaussian(center.y, center.stddev)
      }
      -- Keep points within bounds
      point.x = math.max(config.padding, math.min(config.width - config.padding, point.x))
      point.y = math.max(config.padding, math.min(config.height - config.padding, point.y))
      
      table.insert(points, point)
    end
  end
  
  -- Initialize K-means
  initializeKMeans()
end

function assignPointsToClusters()
  local changed = false
  
  for i, point in ipairs(points) do
    local minDist = math.huge
    local minIdx = 1
    
    for j, center in ipairs(clusterCenters) do
      local dist = distance(point.x, point.y, center.x, center.y)
      if dist < minDist then
        minDist = dist
        minIdx = j
      end
    end
    
    if assignments[i] ~= minIdx then
      changed = true
      assignments[i] = minIdx
    end
  end
  
  return changed
end

function initializeKMeans()
  clusterCenters = {}
  assignments = {}
  converged = false
  iterations = 0
  
  -- Initialize cluster centers randomly from the data points
  local usedIndices = {}
  for i = 1, k do
    local index
    repeat
      index = love.math.random(1, #points)
    until not usedIndices[index]
    usedIndices[index] = true
    
    clusterCenters[i] = {
      x = points[index].x,
      y = points[index].y,
      color = colors[((i - 1) % #colors) + 1]
    }
  end
  
  -- Initial assignment
  assignPointsToClusters()
end

local function updateClusterCenters()
  local counts = {}
  local sums = {}
  
  -- Initialize sums and counts
  for i = 1, k do
    sums[i] = {x = 0, y = 0}
    counts[i] = 0
  end
  
  -- Sum points for each cluster
  for i, point in ipairs(points) do
    local clusterIdx = assignments[i]
    sums[clusterIdx].x = sums[clusterIdx].x + point.x
    sums[clusterIdx].y = sums[clusterIdx].y + point.y
    counts[clusterIdx] = counts[clusterIdx] + 1
  end
  
  -- Update center positions
  for i = 1, k do
    if counts[i] > 0 then
      clusterCenters[i].x = sums[i].x / counts[i]
      clusterCenters[i].y = sums[i].y / counts[i]
    end
  end
end

local function runKMeansIteration()
  if converged or iterations >= config.maxIterations then return end
  
  local changed = assignPointsToClusters()
  updateClusterCenters()
  
  iterations = iterations + 1
  converged = not changed
end

local function isPointInButton(x, y, button)
  return x >= button.x and x <= button.x + button.width and
         y >= button.y and y <= button.y + button.height
end

local function isPointInSlider(x, y, slider)
  return x >= slider.x and x <= slider.x + slider.width and
         y >= slider.y - slider.height/2 and y <= slider.y + slider.height/2
end

local function setSliderValue(x, slider)
  local relativeX = x - slider.x
  local percentage = math.max(0, math.min(1, relativeX / slider.width))
  local range = slider.max - slider.min
  return math.floor(slider.min + percentage * range + 0.5)
end

local function getPointOnVoronoiEdge(x1, y1, x2, y2, width, height, padding)
  -- Find the point where a line from (x1,y1) to (x2,y2) intersects the boundary
  local dx = x2 - x1
  local dy = y2 - y1
  
  -- Check intersection with boundaries
  local tMin = math.huge
  
  -- Left boundary
  if dx < 0 then
    local t = (padding - x1) / dx
    if t < tMin then tMin = t end
  end
  
  -- Right boundary
  if dx > 0 then
    local t = (width - padding - x1) / dx
    if t < tMin then tMin = t end
  end
  
  -- Top boundary
  if dy < 0 then
    local t = (padding - y1) / dy
    if t < tMin then tMin = t end
  end
  
  -- Bottom boundary
  if dy > 0 then
    local t = (height - padding - y1) / dy
    if t < tMin then tMin = t end
  end
  
  if tMin == math.huge then return x2, y2 end
  
  return x1 + dx * tMin, y1 + dy * tMin
end

-- Love2D callback functions
function love.load()
  love.window.setMode(config.width, config.height)
  love.window.setTitle("K-means Clustering Visualization")
  
  -- Set random seed
  love.math.setRandomSeed(os.time())
  
  -- Generate initial data
  generateGaussianClusters()
end

function love.update(dt)
  -- Run K-means iteration automatically if not converged
  if not converged and iterations < config.maxIterations then
    runKMeansIteration()
  end
end

function love.draw()
  -- Clear background
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
  
  -- Draw Voronoi cells if enabled
  if showVoronoi then
    -- Simple Voronoi cell visualization using boundary cells
    local voronoiResolution = 10
    local cellSize = math.min(config.width, config.height) / voronoiResolution
    
    for x = config.padding, config.width - config.padding, cellSize do
      for y = config.padding, config.height - config.padding, cellSize do
        local minDist = math.huge
        local closestCenterIdx = 1
        
        for i, center in ipairs(clusterCenters) do
          local dist = distance(x, y, center.x, center.y)
          if dist < minDist then
            minDist = dist
            closestCenterIdx = i
          end
        end
        
        -- Draw colored cell with alpha
        love.graphics.setColor(
          clusterCenters[closestCenterIdx].color[1], 
          clusterCenters[closestCenterIdx].color[2], 
          clusterCenters[closestCenterIdx].color[3], 
          0.2
        )
        love.graphics.rectangle("fill", x, y, cellSize, cellSize)
      end
    end
  end
  
  -- Draw data points
  for i, point in ipairs(points) do
    local cluster = assignments[i] or 1
    love.graphics.setColor(clusterCenters[cluster].color)
    love.graphics.circle("fill", point.x, point.y, config.pointRadius)
  end
  
  -- Draw cluster centers
  for i, center in ipairs(clusterCenters) do
    -- Draw outer circle
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", center.x, center.y, config.centerRadius + 2)
    
    -- Draw center
    love.graphics.setColor(center.color)
    love.graphics.circle("fill", center.x, center.y, config.centerRadius)
  end
  
  -- Draw semi-transparent UI background panel
  love.graphics.setColor(0.15, 0.15, 0.15, config.uiOpacity)
  love.graphics.rectangle("fill", 
    config.width - config.sliderWidth - config.uiPadding*2, 
    config.uiPadding/2, 
    config.sliderWidth + config.uiPadding*2, 
    config.uiPadding*7 + config.buttonHeight*3 + config.sliderHeight*3)
  
  -- Draw buttons
  love.graphics.setColor(0.3, 0.3, 0.3, 0.9)
  local buttons = {uiState.regenerateButton, uiState.resetKMeansButton, uiState.voronoiButton}
  for _, button in ipairs(buttons) do
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(button.text, button.x, button.y + button.height/3, button.width, "center")
    love.graphics.setColor(0.3, 0.3, 0.3, 0.9)
  end
  
  -- Draw sliders
  local sliders = {uiState.kSlider, uiState.gaussianSlider, uiState.pointsSlider}
  for _, slider in ipairs(sliders) do
    -- Draw slider text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(slider.text, slider.x, slider.y - 20, slider.width, "left")
    
    -- Draw slider track
    love.graphics.setColor(0.3, 0.3, 0.3, 0.9)
    love.graphics.rectangle("fill", slider.x, slider.y - slider.height/2, slider.width, slider.height)
    
    -- Draw slider knob
    local knobPos = slider.x + ((slider.value - slider.min) / (slider.max - slider.min)) * slider.width
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("fill", knobPos, slider.y, config.sliderKnobSize)
    
    -- Draw value
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(tostring(slider.value), slider.x + slider.width + 5, slider.y - 8, 30, "left")
  end
  
  -- Draw status text
  local statusText = "Iterations: " .. iterations
  if converged then
    statusText = statusText .. " (Converged)"
  end
  love.graphics.printf(statusText, 0, config.height - 30, config.width, "center")
  
  -- Data stats
  love.graphics.setColor(0.8, 0.8, 0.8)
  love.graphics.printf(
    "Total points: " .. #points .. 
    " | Gaussian clusters: " .. numGaussians .. 
    " | K-means clusters: " .. k, 
    10, 10, config.width/2, "left")
end

function love.mousepressed(x, y, button)
  if button == 1 then -- Left click
    -- Check buttons
    if isPointInButton(x, y, uiState.regenerateButton) then
      generateGaussianClusters()
      return
    elseif isPointInButton(x, y, uiState.resetKMeansButton) then
      initializeKMeans()
      return
    elseif isPointInButton(x, y, uiState.voronoiButton) then
      showVoronoi = not showVoronoi
      return
    end
    
    -- Check K-means slider
    if isPointInSlider(x, y, uiState.kSlider) then
      local newK = setSliderValue(x, uiState.kSlider)
      if newK ~= k then
        k = newK
        uiState.kSlider.value = k
        initializeKMeans()
      end
      return
    end
    
    -- Check Gaussian clusters slider
    if isPointInSlider(x, y, uiState.gaussianSlider) then
      local newValue = setSliderValue(x, uiState.gaussianSlider)
      if newValue ~= numGaussians then
        numGaussians = newValue
        uiState.gaussianSlider.value = numGaussians
      end
      return
    end
    
    -- Check points per cluster slider
    if isPointInSlider(x, y, uiState.pointsSlider) then
      local newValue = setSliderValue(x, uiState.pointsSlider)
      if newValue ~= pointsPerGaussian then
        pointsPerGaussian = newValue
        uiState.pointsSlider.value = pointsPerGaussian
      end
      return
    end
  end
end

function love.mousemoved(x, y)
  -- Empty, no dragging functionality
end

function love.mousereleased(x, y, button)
  -- Empty, no dragging functionality
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "space" then
    runKMeansIteration()
  elseif key == "r" then
    generateGaussianClusters()
  elseif key == "v" then
    showVoronoi = not showVoronoi
  elseif key == "up" and k < config.maxK then
    k = k + 1
    uiState.kSlider.value = k
    initializeKMeans()
  elseif key == "down" and k > config.minK then
    k = k - 1
    uiState.kSlider.value = k
    initializeKMeans()
  elseif key == "return" or key == "kpenter" then
    generateGaussianClusters()
  end
end