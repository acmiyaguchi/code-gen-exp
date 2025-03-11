function love.conf(t)
    t.title = "Pool Physics Demo"
    t.version = "11.4"  -- Adjust to your LÖVE version
    t.window.width = 800
    t.window.height = 500
    t.window.resizable = false
    t.console = true
    t.modules.audio = false  -- Disable unused modules
    t.modules.sound = false
    t.modules.thread = false
end
