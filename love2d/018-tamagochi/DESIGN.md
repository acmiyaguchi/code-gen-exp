# Love2D Tamagotchi Game Design Document

## Overview
A virtual pet simulation game inspired by the classic Tamagotchi toys, built using the Love2D framework. Players will adopt, care for, and raise a virtual creature through various life stages.

## Core Mechanics
- **Pet Stats**
  - Health: Overall well-being (0-100%)
  - Hunger: Need for food (0-100%, where 0 is full and 100 is starving)
  - Happiness: Emotional state (0-100%)
  - Energy: Activity level (0-100%)
  - Cleanliness: Hygiene level (0-100%)
  
- **Activities**
  - Feed: Reduces hunger, slightly increases energy, slightly decreases cleanliness
  - Play: Increases happiness, decreases energy, slightly increases hunger
  - Clean: Restores cleanliness to maximum, slightly decreases happiness
  - Sleep: Restores energy to maximum, increases hunger while sleeping
  - Medicine: Cures sickness and improves health when sick

- **Life Stages**
  - Egg (1 minute)
  - Baby (5 minutes)
  - Child (10 minutes)
  - Teen (15 minutes)
  - Adult (30 minutes)
  - Elder (20 minutes)

## Game States
1. **Title Screen**
   - New Game option
   - Continue Game option (grayed out if no save exists)
   - Options menu
   
2. **Main Game**
   - Pet view in center
   - Stats display and bars
   - Action buttons at the bottom
   - Day/night cycle affecting background

3. **Future Feature: Mini-games**
   - Simple games to increase happiness/bonding

## Technical Implementation

### Files Structure
```
/main.lua                - Entry point and game loop
/pet.lua                 - Pet class with stats and life stages
/states/                 - Game state management
  /gameState.lua         - Main gameplay state
  /titleState.lua        - Title screen state
/ui/                     - UI components
  /ui.lua                - Interface elements and interactions
/utils/                  - Helper functions
  /saveSystem.lua        - Save/load game state
/assets/                 - Images, sounds, etc.
  /placeholder.lua       - Temporary graphics
```

### Core Systems
1. **Time System**
   - Real-time progression of pet age
   - Day/night cycle (120 seconds per full cycle)
   - Age-based evolution through life stages

2. **Save System**
   - Local storage for game state
   - Auto-save every minute
   - Load/continue capability

3. **Event System**
   - Random events (sickness chance based on health)
   - Death if health reaches zero

4. **Animation System**
   - State-based animations (idle, hungry, tired, sick, etc.)
   - Different appearances per life stage

### UI Design
- Simple, clean interface with stat bars
- Status indicators for all vital stats
- Color-coding for different stats (green for health, orange for hunger, etc.)
- Clear action buttons at the bottom of the screen
- Color changes to indicate day/night cycles

## Pet Behavior
- Stats naturally decay over time:
  - Hunger increases at 0.05% per second
  - Happiness decreases at 0.03% per second
  - Energy decreases at 0.02% per second
  - Cleanliness decreases at 0.04% per second
- Health calculated as average of other stats
- Can become sick if health drops below 30%
- Dies if health reaches zero
- Cannot perform actions while in egg stage or if deceased

## Future Enhancements
1. **Visual Improvements**
   - Replace placeholder graphics with proper pixel art
   - Add animations for each activity and state
   - Transition effects between life stages

2. **Gameplay Expansions**
   - Mini-games for each activity
   - Multiple pet types with different needs
   - Collectibles and achievements

3. **Technical Additions**
   - Sound effects and background music
   - Settings menu for customization
   - Statistics tracking
