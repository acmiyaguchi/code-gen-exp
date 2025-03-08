-- Configuration for LÖVE2D

function love.conf(t)
    t.title = "Love2D Hacker News Client"
    t.version = "11.5"  -- Updated for LÖVE 11.5
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    
    -- Enable required modules
    t.modules.audio = false      -- We don't need audio
    t.modules.joystick = false   -- We don't need joystick
    t.modules.physics = false    -- We don't need physics
    t.modules.sound = false      -- We don't need sound
    t.modules.thread = false     -- Not using Love threads but coroutines
    t.modules.timer = true       -- We need timer for delayed callbacks
    t.modules.graphics = true    -- We need graphics
    t.modules.keyboard = true    -- We need keyboard input
    t.modules.math = true        -- We need math operations
    t.modules.mouse = true       -- We need mouse input
    t.modules.system = true      -- We need system functions
    t.modules.window = true      -- We need window handling
    
    t.console = true             -- Enable console for debugging
    
    -- The external modules we're using (for reference only)
    -- t.externals = {
    --     "luasocket",           -- For HTTP requests
    --     "luasec",              -- For HTTPS support
    -- }
end
