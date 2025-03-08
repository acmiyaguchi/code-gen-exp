local moves = require('moves')

local monsters = {}

-- Monster constructor
local function Monster(name, type, baseStats, moveset)
    return {
        name = name,
        type = type,
        level = 5,
        exp = 0,
        exp_needed = 100,
        current_hp = baseStats.hp,
        base_stats = baseStats,
        stats = {
            hp = baseStats.hp,
            attack = baseStats.attack,
            defense = baseStats.defense,
            sp_attack = baseStats.sp_attack,
            sp_defense = baseStats.sp_defense,
            speed = baseStats.speed
        },
        moves = moveset
    }
end

-- Monster templates
monsters.Blazer = function()
    return Monster(
        "Blazer",
        "Fire",
        {hp = 35, attack = 55, defense = 40, sp_attack = 50, sp_defense = 45, speed = 65},
        {moves.Scorch, moves.Claw}
    )
end

monsters.Aquan = function()
    return Monster(
        "Aquan",
        "Water",
        {hp = 45, attack = 45, defense = 55, sp_attack = 55, sp_defense = 50, speed = 45},
        {moves.AquaJet, moves.Strike}
    )
end

monsters.Terrian = function()
    return Monster(
        "Terrian",
        "Earth",
        {hp = 50, attack = 40, defense = 65, sp_attack = 45, sp_defense = 60, speed = 40},
        {moves.VineLash, moves.Strike}
    )
end

monsters.levelUp = function(monster)
    monster.level = monster.level + 1
    monster.exp = monster.exp - monster.exp_needed
    monster.exp_needed = monster.exp_needed + 20
    
    -- Base stat increases
    monster.stats.hp = monster.stats.hp + 2
    monster.stats.attack = monster.stats.attack + 2
    monster.stats.defense = monster.stats.defense + 2
    monster.stats.sp_attack = monster.stats.sp_attack + 2
    monster.stats.sp_defense = monster.stats.sp_defense + 2
    monster.stats.speed = monster.stats.speed + 2
    
    -- Every 3 levels, add bonus stats based on monster type
    if monster.level % 3 == 0 then
        if monster.name == "Blazer" then
            monster.stats.attack = monster.stats.attack + 2
            monster.stats.speed = monster.stats.speed + 1
        elseif monster.name == "Aquan" then
            monster.stats.sp_attack = monster.stats.sp_attack + 2
            monster.stats.sp_defense = monster.stats.sp_defense + 1
        elseif monster.name == "Terrian" then
            monster.stats.defense = monster.stats.defense + 2
            monster.stats.hp = monster.stats.hp + 1
        end
    end
    
    -- Fully restore HP on level up
    monster.current_hp = monster.stats.hp
    
    return monster
end

return monsters
