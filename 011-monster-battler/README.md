# Monster Battler Demo

A turn-based monster battling game created with LÖVE2D.

## Overview

Monster Battler is a simple game that demonstrates core elements of turn-based monster battling RPGs. Players choose one of three starter monsters and engage in battles against AI opponents.

## Features

- Turn-based battle system with simple animations
- Three unique starter monsters (Blazer, Aquan, Terrian) with different types and stats
- Type effectiveness system (Fire, Water, Earth in a rock-paper-scissors relationship)
- Move selection with different attack categories (Physical/Special)
- Experience system with level progression and stat growth
- Monster stat improvements specific to their type
- Simple overworld state between battles

## Gameplay

1. **Start Screen**: Choose your starter monster from three options:
   - Blazer (Fire type): High attack and speed
   - Aquan (Water type): Balanced stats
   - Terrian (Earth type): High defense and HP

2. **Overworld**: Your monster is shown in a simple overworld screen. Press SPACE to initiate a battle against a random opponent.

3. **Battle System**: 
   - Choose between "Fight" and "Run" options
   - Select moves with different types and power
   - Turn-based combat with effectiveness multipliers
   - Type matchups: Fire > Earth > Water > Fire

4. **Leveling System**:
   - Win battles to gain experience
   - Level up to improve your monster's stats
   - Every three levels, monsters gain bonus stats fitting their type

## Controls

- **Arrow Keys**: Navigate menus
- **Enter/Space**: Confirm selection
- **Escape**: Go back/Quit
- **In overworld**: Press Space to start a battle

## Type Effectiveness

- Fire is strong against Earth, weak against Water
- Water is strong against Fire, weak against Earth
- Earth is strong against Water, weak against Fire
- Neutral moves have no type advantages or disadvantages

## Monster Stats

Each monster has six main stats:
- HP: Health points
- Attack: Physical attack power
- Defense: Physical defense
- Sp. Attack: Special attack power
- Sp. Defense: Special defense
- Speed: Determines turn order

## Running the Game

1. Install LÖVE2D from [https://love2d.org/](https://love2d.org/)
2. Run the game using one of these methods:
   - Drag the game folder onto the LÖVE executable
   - Run `love /path/to/011-monster-battler` from command line
   - Create a .love file by zipping the contents and changing extension

## Project Structure

- **main.lua**: Game state management and main loop
- **conf.lua**: LÖVE configuration settings
- **monsters.lua**: Monster data, stats, and level-up logic
- **moves.lua**: Move definitions and properties
- **battle.lua**: Battle mechanics and damage calculations
- **ui.lua**: User interface rendering
- **images/**: (Placeholder for monster sprites)

## Future Enhancements

- More monsters and moves
- Status effects (Poison, Burn, etc.)
- More complex AI behavior
- A more feature-rich overworld with exploration
- Items and equipment system
- Monster evolution mechanics