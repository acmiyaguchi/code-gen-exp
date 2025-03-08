local battle = {
    state = "ChooseAction", -- ChooseAction, ChooseMove, PlayerAttack, OpponentAttack, Victory, Defeat
    message = "What will you do?",
    selected_option = 1,
    selected_move = 1,
    animation_timer = 0,
    player_monster = nil,
    opponent_monster = nil,
    current_turn = "player",
    battle_ended = false
}

-- Type effectiveness chart
local typeChart = {
    Fire = {
        Fire = 0.5,
        Water = 0.5,
        Earth = 2,
        Neutral = 1
    },
    Water = {
        Fire = 2,
        Water = 0.5,
        Earth = 0.5,
        Neutral = 1
    },
    Earth = {
        Fire = 0.5,
        Water = 2,
        Earth = 0.5,
        Neutral = 1
    },
    Neutral = {
        Fire = 1,
        Water = 1,
        Earth = 1,
        Neutral = 1
    }
}

local function typeEffectiveness(attackType, defendType)
    return typeChart[attackType][defendType]
end

local function calculateDamage(attacker, defender, move)
    local power = move.power
    local attack
    local defense

    if move.category == "Physical" then
        attack = attacker.stats.attack
        defense = defender.stats.defense
    elseif move.category == "Special" then
        attack = attacker.stats.sp_attack
        defense = defender.stats.sp_defense
    end

    local level_factor = 2 * attacker.level / 5 + 2
    local stat_factor = attack / defense
    local base_damage = level_factor * power * stat_factor / 50 + 2
    local type_factor = typeEffectiveness(move.type, defender.type)
    local randomness = math.random(85, 100) / 100
    
    local damage = math.floor(base_damage * type_factor * randomness)
    
    return damage, type_factor
end

function battle.init(player_monster, opponent_monster)
    battle.player_monster = player_monster
    battle.opponent_monster = opponent_monster
    battle.state = "ChooseAction"
    battle.message = "What will " .. player_monster.name .. " do?"
    battle.selected_option = 1
    battle.selected_move = 1
    battle.animation_timer = 0
    battle.battle_ended = false
    battle.current_turn = "player"
end

function battle.update(dt)
    if battle.animation_timer > 0 then
        battle.animation_timer = battle.animation_timer - dt
        if battle.animation_timer <= 0 then
            if battle.state == "PlayerAttack" then
                battle.state = "OpponentAttack"
                battle.message = battle.opponent_monster.name .. " is thinking..."
                battle.animation_timer = 1 -- Give some time before opponent attacks
            elseif battle.state == "OpponentAttack" then
                if battle.player_monster.current_hp <= 0 then
                    battle.state = "Defeat"
                    battle.message = "You lost the battle!"
                    battle.battle_ended = true
                elseif battle.opponent_monster.current_hp <= 0 then
                    battle.state = "Victory"
                    battle.message = "You won the battle!"
                    battle.battle_ended = true
                else
                    battle.state = "ChooseAction"
                    battle.message = "What will " .. battle.player_monster.name .. " do?"
                end
            end
        end
    end
    
    -- AI moves selection
    if battle.state == "OpponentAttack" and battle.animation_timer <= 0 then
        battle.performOpponentTurn()
    end
end

function battle.handleInput(key)
    if battle.animation_timer > 0 then return end
    
    if battle.state == "ChooseAction" then
        if key == "up" or key == "down" then
            battle.selected_option = battle.selected_option == 1 and 2 or 1
        elseif key == "return" or key == "space" then
            if battle.selected_option == 1 then  -- Fight
                battle.state = "ChooseMove"
                battle.message = "Choose a move:"
                battle.selected_move = 1
            elseif battle.selected_option == 2 then  -- Run
                battle.state = "Victory"
                battle.message = "Got away safely!"
                battle.battle_ended = true
            end
        end
    elseif battle.state == "ChooseMove" then
        if key == "up" or key == "down" then
            battle.selected_move = battle.selected_move == 1 and 2 or 1
        elseif key == "return" or key == "space" then
            battle.performPlayerTurn(battle.selected_move)
        elseif key == "escape" then
            battle.state = "ChooseAction"
            battle.message = "What will " .. battle.player_monster.name .. " do?"
        end
    elseif (battle.state == "Victory" or battle.state == "Defeat") and (key == "return" or key == "space") then
        return true  -- Signal to return to overworld
    end
    
    return false
end

function battle.performPlayerTurn(move_index)
    local move = battle.player_monster.moves[move_index]
    local damage, effectiveness = calculateDamage(battle.player_monster, battle.opponent_monster, move)
    battle.opponent_monster.current_hp = math.max(0, battle.opponent_monster.current_hp - damage)
    
    battle.state = "PlayerAttack"
    
    local message = battle.player_monster.name .. " used " .. move.name .. "!"
    if effectiveness > 1 then
        message = message .. " It's super effective!"
    elseif effectiveness < 1 then
        message = message .. " It's not very effective..."
    end
    
    battle.message = message
    battle.animation_timer = 1.5
end

function battle.performOpponentTurn()
    -- Simple AI: randomly choose a move
    local move_index = math.random(1, #battle.opponent_monster.moves)
    local move = battle.opponent_monster.moves[move_index]
    
    local damage, effectiveness = calculateDamage(battle.opponent_monster, battle.player_monster, move)
    battle.player_monster.current_hp = math.max(0, battle.player_monster.current_hp - damage)
    
    local message = battle.opponent_monster.name .. " used " .. move.name .. "!"
    if effectiveness > 1 then
        message = message .. " It's super effective!"
    elseif effectiveness < 1 then
        message = message .. " It's not very effective..."
    end
    
    battle.message = message
    battle.animation_timer = 1.5
end

function battle.awardExperience()
    if battle.state == "Victory" then
        local exp_gain = 50
        battle.player_monster.exp = battle.player_monster.exp + exp_gain
        
        -- Check for level up
        if battle.player_monster.exp >= battle.player_monster.exp_needed then
            local monsters = require("monsters")
            battle.player_monster = monsters.levelUp(battle.player_monster)
            return true
        end
    end
    return false
end

return battle
