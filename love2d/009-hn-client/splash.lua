local splash = {}

-- Load resources when the module is first required
local splashLogo = nil
local splashFont = nil
local initialized = false

-- Initialize the splash screen resources
function splash.init()
  print("Initializing splash screen resources")
  
  if initialized then return end
  
  -- Create a simple logo programmatically 
  splashLogo = love.graphics.newCanvas(200, 200)
  love.graphics.setCanvas(splashLogo)
  love.graphics.clear(0, 0, 0, 0)
  
  -- Draw a simple HN logo
  love.graphics.setColor(1, 0.5, 0)
  love.graphics.rectangle("fill", 40, 20, 40, 160)
  love.graphics.rectangle("fill", 120, 20, 40, 160)
  love.graphics.rectangle("fill", 40, 80, 120, 40)
  
  -- Reset canvas
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1)
  
  -- Font for splash screen
  splashFont = love.graphics.newFont(32)
  
  initialized = true
  print("Splash screen resources initialized")
end

function splash.update(dt)
  -- No update logic needed
  return false
end

function splash.draw()
  -- Initialize resources if not already done
  if not initialized then
    splash.init()
  end

  local windowWidth, windowHeight = love.graphics.getDimensions()
  
  -- Draw background (very important to see the splash)
  love.graphics.setColor(0.1, 0.1, 0.1, 1.0)
  love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
  
  -- Draw logo with slight pulsing effect
  local time = love.timer.getTime()
  local scale = 1.0 + math.sin(time * 3) * 0.05
  
  love.graphics.setColor(1, 1, 1, 1)
  if splashLogo then
    love.graphics.draw(
      splashLogo, 
      windowWidth / 2, 
      windowHeight / 2 - 40, 
      0,  -- rotation
      scale, scale,  -- scale x, y
      splashLogo:getWidth() / 2,  -- origin x
      splashLogo:getHeight() / 2  -- origin y
    )
  else
    -- Fallback if logo creation failed
    love.graphics.setFont(splashFont or love.graphics.newFont(32))
    love.graphics.printf("HN", 0, windowHeight / 2 - 40, windowWidth, "center")
  end
  
  -- Draw application name
  love.graphics.setFont(splashFont or love.graphics.newFont(32))
  love.graphics.printf("Hacker News Client", 0, windowHeight / 2 + 100, windowWidth, "center")
  
  -- Draw loading message
  love.graphics.setFont(love.graphics.newFont(14))
  love.graphics.printf("Loading...", 0, windowHeight / 2 + 150, windowWidth, "center")
  
  -- Draw press any key message
  love.graphics.setFont(love.graphics.newFont(12))
  love.graphics.printf("Press any key to continue", 0, windowHeight - 40, windowWidth, "center")
end

return splash
