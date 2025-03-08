local ui = {}

-- Color constants
local COLORS = {
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    RED = {1, 0, 0},
    GREEN = {0, 1, 0},
    BLUE = {0, 0, 1},
    YELLOW = {1, 1, 0},
    ORANGE = {1, 0.5, 0},
    BACKGROUND = {0.2, 0.6, 0.8},
    MENU_BG = {0.1, 0.1, 0.3, 0.8},
    HP_BAR_BG = {0.3, 0.3, 0.3},
    HP_BAR_GREEN = {0.2, 0.9, 0.2},
    HP_BAR_YELLOW = {0.9, 0.9, 0.2},
    HP_BAR_RED = {0.9, 0.2, 0.2},
    TEXT_SHADOW = {0, 0, 0, 0.5}
}

local TYPE_COLORS = {
    Fire = {1, 0.4, 0.2},
    Water = {0.2, 0.4, 1},
    Earth = {0.4, 0.8, 0.2},
    Neutral = {0.8, 0.8, 0.8}
}

function ui.drawBattleScreen(player_monster, opponent_monster, battle_state)
    -- Draw background
    love.graphics.setColor(COLORS.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw monster sprites
    ui.drawMonsterSprites(player_monster, opponent_monster, battle_state)
    
    -- Draw monster stats areas
    ui.drawMonsterStats(player_monster, "player")
    ui.drawMonsterStats(opponent_monster, "opponent")
    
    -- Draw battle menu
    ui.drawBattleMenu(battle_state)
end

function ui.drawMonsterSprites(player_monster, opponent_monster, battle_state)
    love.graphics.setColor(1, 1, 1)
    
    -- Placeholder for monster sprites
    love.graphics.setColor(TYPE_COLORS[player_monster.type])
    love.graphics.rectangle("fill", 150, 350, 100, 100)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(12)
    love.graphics.print(player_monster.name, 185, 400)
    
    love.graphics.setColor(TYPE_COLORS[opponent_monster.type])
    love.graphics.rectangle("fill", 550, 150, 100, 100)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(12)
    love.graphics.print(opponent_monster.name, 585, 200)
    
    -- Animation for attacks
    if battle_state.state == "PlayerAttack" and battle_state.animation_timer > 0 then
        love.graphics.setColor(1, 1, 1, battle_state.animation_timer)
        love.graphics.circle("fill", 500, 180, 20 * (1 - battle_state.animation_timer))
    elseif battle_state.state == "OpponentAttack" and battle_state.animation_timer > 0 then
        love.graphics.setColor(1, 1, 1, battle_state.animation_timer)
        love.graphics.circle("fill", 200, 380, 20 * (1 - battle_state.animation_timer))
    end
end

function ui.drawMonsterStats(monster, position)
    local x, y, width, height
    
    if position == "player" then
        x, y, width, height = 50, 450, 250, 100
    else
        x, y, width, height = 500, 50, 250, 100
    end
    
    -- Draw stat panel background
    love.graphics.setColor(COLORS.MENU_BG)
    love.graphics.rectangle("fill", x, y, width, height, 10, 10)
    
    -- Draw name and level
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(16)
    love.graphics.print(monster.name .. " Lv." .. monster.level, x + 10, y + 10)
    
    -- Draw HP bar background
    love.graphics.setColor(COLORS.HP_BAR_BG)
    love.graphics.rectangle("fill", x + 10, y + 40, width - 20, 15, 5, 5)
    
    -- Draw HP bar
    local hp_percent = monster.current_hp / monster.stats.hp
    local hp_color
    if hp_percent > 0.5 then
        hp_color = COLORS.HP_BAR_GREEN
    elseif hp_percent > 0.2 then
        hp_color = COLORS.HP_BAR_YELLOW
    else
        hp_color = COLORS.HP_BAR_RED
    end
    
    love.graphics.setColor(hp_color)
    love.graphics.rectangle("fill", x + 10, y + 40, (width - 20) * hp_percent, 15, 5, 5)
    
    -- Draw HP text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(12)
    love.graphics.print("HP: " .. monster.current_hp .. "/" .. monster.stats.hp, x + 10, y + 60)
    
    -- Draw type icon
    love.graphics.setColor(TYPE_COLORS[monster.type])
    love.graphics.rectangle("fill", x + width - 30, y + 10, 20, 20, 5, 5)
    
    -- Draw EXP bar for player monster
    if position == "player" then
        love.graphics.setColor(COLORS.HP_BAR_BG)
        love.graphics.rectangle("fill", x + 10, y + 80, width - 20, 5, 2, 2)
        
        local exp_percent = monster.exp / monster.exp_needed
        love.graphics.setColor(COLORS.BLUE)
        love.graphics.rectangle("fill", x + 10, y + 80, (width - 20) * exp_percent, 5, 2, 2)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(10)
        love.graphics.print("EXP: " .. monster.exp .. "/" .. monster.exp_needed, x + 10, y + 85)
    end
end

function ui.drawBattleMenu(battle_state)
    -- Draw message box
    love.graphics.setColor(COLORS.MENU_BG)
    love.graphics.rectangle("fill", 50, 50, 700, 60, 10, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(18)
    love.graphics.print(battle_state.message, 70, 70)
    
    -- Draw action menu only when in appropriate states
    if battle_state.state == "ChooseAction" then
        love.graphics.setColor(COLORS.MENU_BG)
        love.graphics.rectangle("fill", 550, 450, 200, 120, 10, 10)
        
        love.graphics.setNewFont(20)
        love.graphics.setColor(1, 1, 1)
        
        -- Draw options
        local options = {"Fight", "Run"}
        for i, option in ipairs(options) do
            if i == battle_state.selected_option then
                love.graphics.setColor(COLORS.YELLOW)
                love.graphics.print("> " .. option, 570, 470 + (i-1) * 40)
            else
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("  " .. option, 570, 470 + (i-1) * 40)
            end
        end
    elseif battle_state.state == "ChooseMove" then
        love.graphics.setColor(COLORS.MENU_BG)
        love.graphics.rectangle("fill", 50, 450, 450, 120, 10, 10)
        
        love.graphics.setNewFont(18)
        
        -- Draw move options
        for i, move in ipairs(battle_state.player_monster.moves) do
            if i == battle_state.selected_move then
                love.graphics.setColor(COLORS.YELLOW)
                love.graphics.print("> " .. move.name, 70, 470 + (i-1) * 40)
            else
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("  " .. move.name, 70, 470 + (i-1) * 40)
            end
            
            -- Draw move type
            love.graphics.setColor(TYPE_COLORS[move.type])
            love.graphics.rectangle("fill", 200, 475 + (i-1) * 40, 60, 20, 5, 5)
            love.graphics.setColor(0, 0, 0)
            love.graphics.setNewFont(12)
            love.graphics.print(move.type, 210, 478 + (i-1) * 40)
            
            -- Draw move category
            love.graphics.setColor(1, 1, 1)
            love.graphics.setNewFont(14)
            love.graphics.print(move.category, 280, 475 + (i-1) * 40)
            
            -- Draw move power
            love.graphics.print("Power: " .. move.power, 380, 475 + (i-1) * 40)
        end
    end
    
    -- Draw instructions
    if battle_state.state == "Victory" or battle_state.state == "Defeat" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(16)
        love.graphics.print("Press Enter to continue", 300, 530)
    end
end

function ui.drawOverworld(player_monster)
    -- Simple overworld view
    love.graphics.setColor(0.1, 0.6, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.rectangle("fill", 100, 100, 600, 400, 10, 10)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.setNewFont(24)
    love.graphics.print("Monster Battler Demo", 300, 130)
    
    love.graphics.setNewFont(18)
    love.graphics.print("Your Monster: " .. player_monster.name .. " (Lv. " .. player_monster.level .. ")", 200, 200)
    love.graphics.print("Press SPACE to start a battle", 250, 300)
    love.graphics.print("Press ESC to quit", 250, 350)
    
    -- Draw monster icon
    love.graphics.setColor(TYPE_COLORS[player_monster.type])
    love.graphics.rectangle("fill", 150, 200, 30, 30, 5, 5)
end

function ui.drawLevelUp(monster, old_stats)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(0.2, 0.2, 0.6)
    love.graphics.rectangle("fill", 200, 150, 400, 300, 10, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(24)
    love.graphics.print(monster.name .. " leveled up!", 260, 170)
    love.graphics.setNewFont(20)
    love.graphics.print("Level: " .. (monster.level - 1) .. " -> " .. monster.level, 260, 220)
    
    -- Draw stat changes
    local y = 260
    local stats = {"hp", "attack", "defense", "sp_attack", "sp_defense", "speed"}
    local stat_names = {hp = "HP", attack = "Attack", defense = "Defense", sp_attack = "Sp. Atk", sp_defense = "Sp. Def", speed = "Speed"}
    
    love.graphics.setNewFont(16)
    for _, stat in ipairs(stats) do
        local old_value = old_stats[stat]
        local new_value = monster.stats[stat]
        
        love.graphics.print(stat_names[stat] .. ": " .. old_value .. " -> " .. new_value, 260, y)
        y = y + 30
    end
    
    love.graphics.setNewFont(18)
    love.graphics.print("Press ENTER to continue", 290, 410)
end

function ui.drawStartScreen(selected_monster)
    love.graphics.setColor(0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(36)
    love.graphics.print("Monster Battler", 260, 100)
    
    love.graphics.setNewFont(24)
    love.graphics.print("Choose your starter monster:", 250, 180)
    
    local options = {"Blazer", "Aquan", "Terrian"}
    local descriptions = {
        "Fire type. High attack and speed.",
        "Water type. Balanced stats.",
        "Earth type. High defense and HP."
    }
    local x_positions = {200, 350, 500}
    
    for i, option in ipairs(options) do
        if i == selected_monster then
            love.graphics.setColor(COLORS.YELLOW)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.setNewFont(20)
        love.graphics.print(option, x_positions[i], 250)
        
        love.graphics.setColor(TYPE_COLORS[i == 1 and "Fire" or i == 2 and "Water" or "Earth"])
        love.graphics.rectangle("fill", x_positions[i], 280, 80, 80)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(14)
        love.graphics.print(descriptions[i], x_positions[i] - 30, 370)
    end
    
    love.graphics.setNewFont(18)
    love.graphics.print("Use LEFT/RIGHT to select, ENTER to confirm", 220, 450)
end

return ui
