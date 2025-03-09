function love.conf(t)
    t.title = "Chess with miniKanren"
    t.version = "11.3"
    t.window.width = 800
    t.window.height = 600
    
    -- For debugging
    t.console = true
    
    -- Disable unused modules
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.video = false
end
