# Pokémon Pixel Art Generator

## Overview
A Love2D application that procedurally generates pixel art versions of the three starter Pokémon: Charmander, Bulbasaur, and Squirtle. When not displayed, Pokémon are shown as being inside a Pokeball.

## Features
- Procedural generation of pixel art for Charmander, Bulbasaur, and Squirtle
- Ability to cycle through different Pokémon using keyboard or mouse
- Animated transition between Pokémon and Pokeball
- Color palette customization options

## Technical Design

### Components
1. **Main Module** (`main.lua`)
   - Initializes Love2D
   - Handles input events
   - Manages game state
   - Coordinates rendering

2. **Pokemon Generator** (`pokemon.lua`) 
   - Contains algorithms for procedurally generating each Pokémon
   - Defines base templates and variation parameters
   - Handles color selection and pixel placement

3. **Pokeball Renderer** (`pokeball.lua`)
   - Renders Pokeball when Pokémon are not displayed
   - Handles transition animations

4. **Input Handler** (`input.lua`)
   - Processes keyboard and mouse inputs
   - Maps inputs to actions

### Procedural Generation Approach
Each Pokémon will be generated using a combination of:
- Base templates defining the general shape and proportions
- Controlled randomization of specific features (patterns, small details)
- Consistent color palettes with slight variations
- Pixel-by-pixel rendering with coherent noise patterns

### User Interaction
- Arrow keys or A/D to cycle through Pokémon
- Mouse click to select/deselect a Pokémon
- Space bar to regenerate current Pokémon with new variation

## Implementation Plan
1. Create basic application structure and input handling
2. Implement Pokeball rendering
3. Develop procedural generation algorithm for each Pokémon
4. Add transitions between Pokémon and Pokeball
5. Implement cycling functionality
6. Add color customization options
7. Polish and optimize

## Technical Constraints
- Pure Love2D implementation with no external dependencies
- Efficient rendering to maintain smooth performance
- Consistent pixel art style across all generated content