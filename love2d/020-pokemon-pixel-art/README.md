# Pokémon Pixel Art Generator

A Love2D application that procedurally generates pixel art of the three starter Pokémon: Bulbasaur, Charmander, and Squirtle.

## Features

- Procedurally generated pixel art for Bulbasaur, Charmander, and Squirtle
- Pokéball animations when Pokémon are not being displayed
- Simple controls for cycling between Pokémon and regenerating variations

## Controls

- **Left/Right Arrow Keys or A/D:** Cycle between Pokémon
- **Up/Down Arrow Keys or W/S:** Change pixel resolution (16×16, 32×32, 64×64)
- **Space:** Regenerate the current Pokémon with new variations
- **Enter/P or Mouse Click:** Toggle between Pokémon and Pokéball

## Running the Application

1. Install Love2D (https://love2d.org/)
2. Navigate to this directory
3. Run with Love2D:
   ```
   love .
   ```

## Technical Details

This application uses procedural generation with noise functions to create unique variations of each Pokémon while maintaining their recognizable characteristics. All artwork is generated at runtime using Love2D's graphics capabilities with no external dependencies.