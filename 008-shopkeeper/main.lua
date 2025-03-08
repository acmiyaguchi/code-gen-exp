local Shopkeeper = require 'shopkeeper'
local DialogueSystem = require 'dialogue'
local Shop = require 'shop'

function love.load()
    -- Game state
    gameState = "playing" -- "playing", "dialogue", "shopping"
    
    -- Initialize entities
    shopkeeper = Shopkeeper.new()
    
    -- Player data
    player = { 
        x = 100, 
        y = 100, 
        speed = 200,
        inventory = {},
        gold = 500
    }
    
    -- Add some starting items
    player.inventory = {
        {name = "Potion", quantity = 2},
        {name = "Antidote", quantity = 1}
    }
    
    -- Initialize systems
    dialogueSystem = DialogueSystem.new()
    shop = Shop.new(shopkeeper.items)
    
    -- Load fonts
    font = love.graphics.newFont(14)
    headerFont = love.graphics.newFont(18)
    love.graphics.setFont(font)
    
    -- UI elements
    dialogBoxHeight = 150
    windowHeight = love.graphics.getHeight()
    windowWidth = love.graphics.getWidth()
end

function love.update(dt)
    if gameState == "playing" then
        shopkeeper:update(dt)
        updatePlayer(dt)
    elseif gameState == "dialogue" then
        dialogueSystem:update(dt)
    elseif gameState == "shopping" then
        shop:update(dt)
    end
end

function love.draw()
    -- Draw the game world
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight) -- Background
    
    -- Draw shop area
    love.graphics.setColor(0.6, 0.6, 0.7)
    love.graphics.rectangle("fill", 150, 150, 300, 200) -- Shop area
    
    -- Draw entities
    love.graphics.setColor(1, 0, 0)
    shopkeeper:draw()
    
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", player.x, player.y, 32, 32) -- Draw player
    
    -- Draw status bar
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Gold: " .. player.gold, 10, 10)
    
    -- Draw UI based on game state
    if gameState == "dialogue" then
        dialogueSystem:draw()
    elseif gameState == "shopping" then
        shop:draw()
    end
end

function updatePlayer(dt)
    if gameState ~= "playing" then return end
    
    local moved = false
    
    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
        moved = true
    elseif love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
        moved = true
    end
    
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
        moved = true
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
        moved = true
    end
end

function love.keypressed(key)
    if key == "escape" then
        -- Emergency exit from any state back to playing
        if gameState == "dialogue" or gameState == "shopping" then
            gameState = "playing"
            return
        end
    end
    
    if gameState == "playing" then
        if key == "space" then
            if shopkeeper.state == 'greeting' then
                local dialogue = shopkeeper:getGreetingDialogue()
                if dialogue and #dialogue > 0 then
                    dialogueSystem:startDialogue(dialogue)
                    gameState = "dialogue"
                end
            end
        end
    elseif gameState == "dialogue" then
        dialogueSystem:handleInput(key)
        
        if dialogueSystem.finished then
            if dialogueSystem.nextAction == "shop" then
                gameState = "shopping"
                shop:open(player)
                dialogueSystem.nextAction = nil
            else
                gameState = "playing"
            end
        end
    elseif gameState == "shopping" then
        shop:handleInput(key)
        
        if shop.closed then
            gameState = "playing"
        end
    end
end

function love.mousepressed(x, y, button)
    if gameState == "dialogue" then
        dialogueSystem:handleMouseClick(x, y, button)
    elseif gameState == "shopping" then
        shop:handleMouseClick(x, y, button)
    end
end
