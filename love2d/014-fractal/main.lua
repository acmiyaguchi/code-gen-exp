-- Fractal Viewer
-- A simple Love2D Mandelbrot set fractal viewer with mouse controls

-- Configuration
local config = {
    maxIterations = 100,
    escapeRadius = 2.0,
    zoomSpeed = 0.1,
    colorCycles = 5
}

-- View state
local view = {
    centerX = 0.0,
    centerY = 0.0,
    scale = 0.005,
    isDragging = false,
    lastMouseX = 0,
    lastMouseY = 0
}

function love.load()
    love.window.setTitle("Fractal Viewer")
    love.window.setMode(800, 600)
    
    -- Create a canvas to draw the fractal
    canvas = love.graphics.newCanvas(800, 600)
    
    -- Initial render
    updateFractal()
end

function love.update(dt)
    -- Only re-render if the view has changed
    if view.needsUpdate then
        updateFractal()
        view.needsUpdate = false
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas)
    
    -- Draw instructions
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print("Mouse wheel: Zoom in/out", 10, 10)
    love.graphics.print("Click and drag: Pan", 10, 30)
    love.graphics.print("R: Reset view", 10, 50)
    love.graphics.print(string.format("Scale: %.8f", view.scale), 10, 70)
    love.graphics.print(string.format("Center: %.6f, %.6f", view.centerX, view.centerY), 10, 90)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        view.isDragging = true
        view.lastMouseX = x
        view.lastMouseY = y
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        view.isDragging = false
    end
end

function love.mousemoved(x, y, dx, dy)
    if view.isDragging then
        -- Update center position based on mouse movement
        view.centerX = view.centerX - dx * view.scale
        view.centerY = view.centerY - dy * view.scale
        view.needsUpdate = true
    end
end

function love.wheelmoved(x, y)
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    
    -- Convert mouse position to fractal coordinates before zoom
    local fractalX = (mouseX - love.graphics.getWidth() / 2) * view.scale + view.centerX
    local fractalY = (mouseY - love.graphics.getHeight() / 2) * view.scale + view.centerY
    
    -- Adjust scale based on wheel movement
    if y > 0 then
        view.scale = view.scale * (1 - config.zoomSpeed)
    elseif y < 0 then
        view.scale = view.scale * (1 + config.zoomSpeed)
    end
    
    -- Adjust center to zoom on mouse position
    view.centerX = fractalX - (mouseX - love.graphics.getWidth() / 2) * view.scale
    view.centerY = fractalY - (mouseY - love.graphics.getHeight() / 2) * view.scale
    
    view.needsUpdate = true
end

function love.keypressed(key)
    if key == "r" then
        -- Reset view
        view.centerX = 0.0
        view.centerY = 0.0
        view.scale = 0.005
        view.needsUpdate = true
    end
end

function updateFractal()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            -- Convert screen coordinates to fractal coordinates
            local real = (x - width / 2) * view.scale + view.centerX
            local imag = (y - height / 2) * view.scale + view.centerY
            
            local iterations = calculateMandelbrot(real, imag)
            
            -- Set pixel color based on iteration count
            local r, g, b = getColor(iterations)
            love.graphics.setColor(r, g, b, 1)
            love.graphics.points(x, y)
        end
    end
    
    love.graphics.setCanvas()
end

function calculateMandelbrot(startReal, startImag)
    local real = 0
    local imag = 0
    local iteration = 0
    
    while (real * real + imag * imag <= config.escapeRadius * config.escapeRadius) and (iteration < config.maxIterations) do
        local tempReal = real * real - imag * imag + startReal
        imag = 2 * real * imag + startImag
        real = tempReal
        iteration = iteration + 1
    end
    
    -- Smooth coloring - returns a fractional value for smoother color transitions
    if iteration < config.maxIterations then
        -- Smooth coloring formula
        local log_zn = math.log(real * real + imag * imag) / 2
        local nu = math.log(log_zn / math.log(2)) / math.log(2)
        iteration = iteration + 1 - nu
    end
    
    return iteration
end

function getColor(iterations)
    if iterations >= config.maxIterations then
        -- Points inside the set are black
        return 0, 0, 0
    else
        -- Use a cyclic color palette with smooth transitions
        local t = iterations / config.maxIterations
        local cyclePos = (t * config.colorCycles) % 1
        
        -- HSV to RGB conversion (simplified)
        local h = cyclePos * 360
        local s = 0.8
        local v = 1.0
        
        -- HSV to RGB conversion
        local c = v * s
        local x = c * (1 - math.abs((h / 60) % 2 - 1))
        local m = v - c
        
        local r, g, b = 0, 0, 0
        
        if h < 60 then
            r, g, b = c, x, 0
        elseif h < 120 then
            r, g, b = x, c, 0
        elseif h < 180 then
            r, g, b = 0, c, x
        elseif h < 240 then
            r, g, b = 0, x, c
        elseif h < 300 then
            r, g, b = x, 0, c
        else
            r, g, b = c, 0, x
        end
        
        return r + m, g + m, b + m
    end
end
