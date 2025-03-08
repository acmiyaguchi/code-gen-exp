local monsters = require("monsters")
local battle = require("battle")
local ui = require("ui")

-- Game states: "start", "overworld", "battle", "levelup"
local game_state = "start"
local player_monster = nil
local opponent_monster = nil
local selected_starter = 1
local old_stats = {}

function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.update(dt)
    if game_state == "battle" then
        battle.update(dt)
    end
end

function love.draw()
    if game_state == "start" then
        ui.drawStartScreen(selected_starter)
    elseif game_state == "overworld" then
        ui.drawOverworld(player_monster)
    elseif game_state == "battle" then
        ui.drawBattleScreen(player_monster, opponent_monster, battle)
    elseif game_state == "levelup" then
        ui.drawLevelUp(player_monster, old_stats)
    end
end

function love.keypressed(key)
    if game_state == "start" then
        handleStartInput(key)
    elseif game_state == "overworld" then
        handleOverworldInput(key)
    elseif game_state == "battle" then
        local battle_ended = battle.handleInput(key)
        if battle_ended then
            if battle.state == "Victory" then
                -- Check if monster leveled up
                old_stats = {
                    hp = player_monster.stats.hp,
                    attack = player_monster.stats.attack,
                    defense = player_monster.stats.defense,
                    sp_attack = player_monster.stats.sp_attack,
                    sp_defense = player_monster.stats.sp_defense,
                    speed = player_monster.stats.speed
                }
                
                local leveled_up = battle.awardExperience()
                if leveled_up then
                    game_state = "levelup"
                else
                    game_state = "overworld"
                end
            else
                game_state = "overworld"
            end
        end
    elseif game_state == "levelup" then
        if key == "return" or key == "space" then
            game_state = "overworld"
        end
    end
    
    if key == "escape" then
        love.event.quit()
    end
end

function handleStartInput(key)
    if key == "left" then
        selected_starter = selected_starter - 1
        if selected_starter < 1 then selected_starter = 3 end
    elseif key == "right" then
        selected_starter = selected_starter + 1
        if selected_starter > 3 then selected_starter = 1 end
    elseif key == "return" or key == "space" then
        -- Create the player's monster based on selection
        if selected_starter == 1 then
            player_monster = monsters.Blazer()
        elseif selected_starter == 2 then
            player_monster = monsters.Aquan()
        else
            player_monster = monsters.Terrian()
        end
        
        -- Move to the overworld state
        game_state = "overworld"
    end
end

function handleOverworldInput(key)
    if key == "space" then
        -- Start a random battle
        local opponent_types = {"Blazer", "Aquan", "Terrian"}
        local random_type = math.random(1, 3)
        
        if opponent_types[random_type] == "Blazer" then
            opponent_monster = monsters.Blazer()
        elseif opponent_types[random_type] == "Aquan" then
            opponent_monster = monsters.Aquan()
        else
            opponent_monster = monsters.Terrian()
        end
        
        -- Ensure monster is fully healed before battle
        player_monster.current_hp = player_monster.stats.hp
        
        -- Initialize battle
        battle.init(player_monster, opponent_monster)
        game_state = "battle"
    end
end