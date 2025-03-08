# Monster Battler Demo - Design Document

## 1. Introduction

This document outlines the design for a simplified monster battling demo created using the LÖVE2D framework. The demo focuses on a core, turn-based battle system featuring three monsters in a classic "rock-paper-scissors" type triangle (Fire, Water, Earth). It includes basic UI elements, a simplified damage calculation system, and a rudimentary experience and leveling system.

## 2. Game Mechanics

*   **Turn-Based Combat:** The battle proceeds in turns. Each turn, the player and the opponent (AI) choose an action.
*   **Monster Selection:** The player starts with one of the three starter monsters. The opponent will be randomly chosen from the same pool. For the demo, there is no switching of monsters.
*   **Actions:**
    *   **Fight:** Select a move to use against the opponent.
    *   **Run:** Attempt to escape the battle (for the demo, this will always succeed and end the battle).
*   **Type Effectiveness:** A simplified type effectiveness system is used:
    *   Fire is strong against Earth, weak against Water.
    *   Water is strong against Fire, weak against Earth.
    *   Earth is strong against Water, weak against Fire.
    *   Neutral moves are neutral against all types.
    *   Super Effective: 2x damage
    *   Not Very Effective: 0.5x damage
    *   Normal: 1x damage
*   **Win Condition:** When a monster's HP reaches zero, it loses.

## 3. Monsters and Moves

| Monster    | Type  | HP   | Attack | Defense | Sp. Attack | Sp. Defense | Speed | Moves                    |
| :--------- | :---- | :--- | :----- | :------ | :-------- | :---------- | :---- | :----------------------- |
| Blazer     | Fire  | 35   | 55     | 40      | 50        | 45          | 65    | Scorch, Claw          |
| Aquan      | Water | 45   | 45     | 55      | 55        | 50          | 45    | Aqua Jet, Strike        |
| Terrian    | Earth | 50   | 40     | 65      | 45        | 60          | 40    | Vine Lash, Strike         |

| Move        | Type   | Power | Accuracy | PP  | Category  |
| :---------- | :----- | :---- | :------- | :-- | :-------- |
| Strike      | Neutral | 40    | 100      | 35  | Physical  |
| Claw     | Neutral | 40    | 100      | 35  | Physical  |
| Scorch       | Fire   | 40    | 100      | 25  | Special   |
| Aqua Jet   | Water  | 40    | 100      | 25  | Special   |
| Vine Lash  | Earth  | 45    | 100      | 25  | Physical  |

## 4. Stats and Stat Growth

*   **Stats:** Each monster has the following stats:
    *   HP (Hit Points): Determines how much damage the monster can take before fainting.
    *   Attack: Affects the damage of Physical moves.
    *   Defense: Reduces damage taken from Physical moves.
    *   Sp. Attack (Special Attack): Affects the damage of Special moves.
    *   Sp. Defense (Special Defense): Reduces damage taken from Special moves.
    *   Speed: Determines which monster acts first in a turn.
    *   Experience
    *   Level

*   **Experience and Leveling:**
    *   Monsters gain experience points (EXP) after winning a battle.
    *   When a monster gains enough EXP, it levels up.
    *   For the demo, a simple EXP system is used: Winning a battle grants a fixed amount of EXP (e.g., 50 EXP).
    *   Leveling up increases the monster's level.
    *   Each monster will start at level 5.
*   **Stat Growth per Level (Simplified):**
    *   For simplicity, we'll use a fixed increase for each stat per level.
        *   On level gain, increase all stats by two.
        *   Every three levels, provide a bonus to specific stats:
            *   Blazer: +2 Attack, +1 Speed (Focus on offense)
            *   Aquan: +2 Sp. Attack, +1 Sp. Defense (Focus on special stats)
            *   Terrian: +2 Defense, +1 HP (Focus on bulk)
    *  When the player wins, transition back to the "overworld" gamestate.

## 5. Damage Calculation

```lua
local function calculateDamage(attacker, defender, move)
    local power = move.power
    local attack
    local defense

    if move.category == "Physical" then
        attack = attacker.attack
        defense = defender.defense
    elseif move.category == "Special" then
        attack = attacker.sp_attack
        defense = defender.sp_defense
    end

    local damage = (22 * power * (attack / defense) / 50 + 2) * typeEffectiveness(move.type, defender.type)
    damage = damage * (math.random(85, 100) / 100)  -- Randomness
    return math.floor(damage)
end

--Type effectiveness
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
```

## 6. User Interface (UI)

The UI will be divided into four main areas:

1.  **Opponent Monster Area (Top):**
    *   Monster Name (Text)
    *   HP Bar (Rectangle - with inner rectangle for remaining HP)
    *   HP Value (Text - optional)

2.  **Player Monster Area (Bottom):**
    *   Monster Name (Text)
    *   HP Bar (Rectangle - with inner rectangle for remaining HP)
    *   HP Value (Text - optional)

3.  **Visual/Action Area (Center):**
    *   Opponent Monster Sprite
    *   Player Monster Sprite

4.  **Command Area (Bottom-Right or Bottom):**
    *   Menu Options: "Fight", "Run"
    *   Cursor/Highlight to indicate selection
    *   When "Fight" is selected, a sub-menu displays the monster's moves.

## 7. Game States

*   **Overworld:** The player can move around (not implemented in this demo).
*   **Battle:** The core battle sequence.
    *   **ChooseAction:** Player selects "Fight" or "Run".
    *   **ChooseMove:** Player selects a move (if "Fight" was chosen).
    *   **Attacking:** Animation and damage calculation are performed.
    *   **OpponentTurn:** The AI chooses a move and attacks.
    *   **Victory/Defeat:** Transition states after a monster faints.

## 8. Code Structure (Suggested)

```
/
├── main.lua          -- Main game logic, state management, loop
├── conf.lua          -- LÖVE configuration (window size, etc.)
├── monsters.lua       -- Monster data (stats, moves)
├── moves.lua         -- Move data (power, type, etc.)
├── battle.lua        -- Battle logic (turn order, damage, AI)
├── ui.lua            -- UI drawing and input handling
└── images/           -- Sprites for monsters and UI elements
    ├── blazer.png
    ├── aquan.png
    └── terrian.png
```

## 9. Implementation Steps (Recap)

1.  **Setup:** Create the project structure and basic LÖVE2D setup (conf.lua, main.lua).
2.  **Data:** Define monster and move data in `monsters.lua` and `moves.lua`.
3.  **UI:** Implement the basic UI layout in `ui.lua`.
4.  **Battle Logic:** Implement the core battle loop, turn handling, and damage calculation in `battle.lua`.
5.  **AI:** Implement a simple AI for the opponent (random move selection).
6.  **Input Handling:** Handle player input for menu navigation and move selection in `ui.lua` and `battle.lua`.
7.  **State Management:** Implement the game state transitions in `main.lua`.
8.  **Experience/Leveling:** Add the experience and leveling system to `battle.lua` and `monsters.lua`.
9.  **Testing:** Thoroughly test after each major milestone.

## 10. Future Enhancements (Beyond the Demo)

*   More monsters and moves.
*   More complex AI.
*   Status effects (Poison, Burn, etc.).
*   Stat-changing moves.
*   A more complete overworld.
*   Items.
*   Monster evolution.