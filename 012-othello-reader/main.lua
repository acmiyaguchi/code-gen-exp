local Parser = require('parser')
local Menu = require('menu')
local Reader = require('reader')
local UI = require('ui')

local state = {
    mode = "menu", -- "menu" or "reader"
    play_data = nil,
    current_act = 1,
    current_scene = 1,
}

function love.load()
    -- Set default font and window title
    love.window.setTitle("Othello Interactive Reader")
    
    -- Make sure we can load files from the current directory
    love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";?.lua")
    
    -- Check if the text file exists
    if not love.filesystem.getInfo("pg1531.txt") then
        print("Error: pg1531.txt not found. Please place it in the same directory as main.lua")
        print("Current directory: " .. love.filesystem.getWorkingDirectory())
        print("App directory: " .. love.filesystem.getSourceBaseDirectory())
        return
    end
    
    -- Parse the play data
    state.play_data = Parser.parse_play_file("pg1531.txt")
    
    -- Initialize UI
    UI.init()
    
    -- Initialize modules with the state
    Menu.init(state)
    Reader.init(state)
end

function love.update(dt)
    if state.mode == "menu" then
        Menu.update(dt)
    elseif state.mode == "reader" then
        Reader.update(dt)
    end
end

function love.draw()
    -- Draw simple background
    love.graphics.setColor(UI.colors.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color
    
    if state.mode == "menu" then
        Menu.draw()
    elseif state.mode == "reader" then
        Reader.draw()
    end
end

function love.mousepressed(x, y, button)
    if state.mode == "menu" then
        Menu.mousepressed(x, y, button)
    elseif state.mode == "reader" then
        Reader.mousepressed(x, y, button)
    end
end

function love.wheelmoved(x, y)
    if state.mode == "reader" then
        Reader.wheelmoved(x, y)
    end
end

function love.keypressed(key)
    if state.mode == "reader" then
        Reader.keypressed(key)
    end
end
