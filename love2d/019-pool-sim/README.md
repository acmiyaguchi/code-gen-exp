# Pool Physics Demo

A physics-based pool (billiards) simulation built with LÖVE2D to demonstrate the capabilities of the Box2D physics engine.

## Overview

This project showcases a simplified 9-ball pool game that focuses on accurate physics simulation rather than complex game rules. The demo emphasizes realistic ball collisions, cushion rebounds, and basic spin mechanics, providing an interactive way to explore 2D physics.

## Features

- Realistic physics simulation using LÖVE2D's Box2D implementation
- Intuitive mouse-controlled aiming and power system
- Basic spin (english) control with keyboard input
- 9-ball rack setup with accurate triangle formation
- Pocket detection and ball removal
- Visual debugging tools to see physics properties

## Controls

- **Mouse movement**: Aim the cue
- **Left-click and drag**: Set power and direction
- **Left/Right arrow keys**: Apply left/right spin (english)
- **Down arrow key**: Reset spin to neutral
- **D key**: Toggle debug mode
- **R key**: Reset the game
- **Escape**: Quit the game

## Code Structure

The project is organized in an object-oriented manner with the following components:

- **Ball.lua**: Represents a pool ball with physics properties
- **Table.lua**: Defines the pool table, cushions, and pockets
- **Player.lua**: Handles player input and cue stick control
- **Game.lua**: Manages game state and coordinates all objects
- **main.lua**: Entry point for the LÖVE2D application
- **conf.lua**: LÖVE2D configuration

## Running the Game

1. Install LÖVE2D from [love2d.org](https://love2d.org/)
2. Clone this repository
3. Run the game with: `love /path/to/019-pool-sim`

## Implementation Notes

- The physics world uses zero gravity for top-down simulation
- Balls use CircleShape bodies with appropriate restitution and friction
- Table cushions are implemented using static EdgeShape bodies
- Pockets use sensor fixtures to detect when balls are pocketed
- Linear and angular damping are used to simulate friction
- The game uses a simplified state system: aiming, shooting, waiting, and gameover

## Debug Mode

Pressing 'D' toggles debug visualization which shows:
- Physics bodies outlines
- Velocity vectors for balls
- Pocket sensor boundaries
- Table edge collision shapes

## License

This project is provided as an educational example. Feel free to use and modify for your own learning.
