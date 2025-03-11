# Pool Physics Demo Design Document

## Overview
A technical demonstration of LÖVE2D's physics capabilities through a streamlined pool (billiards) simulator. This demo focuses on accurate physics implementation while maintaining essential gameplay mechanics.

## Core Technical Demo Goals
- Showcase LÖVE2D's physics engine capabilities
- Demonstrate realistic ball collisions and momentum transfer
- Provide a playable 9-ball pool experience with minimal assets
- Create a clear visual representation of physics principles in action

## Architecture

The application follows an object-oriented design with the following main components:

### Game
- Central controller that manages the game state and coordinates all game objects
- Handles game loop (update and draw cycles)
- Manages physics world and collision callbacks
- Processes input and routes it to the appropriate objects
- Controls game state transitions (aiming, shooting, waiting, gameover)

### Ball
- Represents a pool ball with physics properties
- Handles rendering and movement
- Includes simplified physics damping to simulate friction
- Supports basic spin (english) effects
- Tracks pocketed state and handles resets

### Table
- Manages the pool table representation
- Creates cushions (edges) with appropriate physics properties
- Implements pockets using sensor fixtures
- Handles visual rendering of the table surface

### Player
- Controls for aiming and striking the cue ball
- Supports power control through drag distance
- Implements simple spin control through keyboard input
- Visualizes aiming line and cue stick

## Physics Implementation

### Physics Engine Highlights
- Ball-to-ball collisions with proper momentum transfer
- Surface friction simulated through linear damping
- Cushion rebounds with appropriate restitution values
- Velocity decay to simulate rolling resistance
- Pocket detection using sensor fixtures
- Zero gravity physics world for top-down simulation

### Ball Properties
- 10 balls total (cue ball + 9 numbered balls)
- Consistent mass and size properties
- Restitution ~0.9 for realistic bounce
- Linear damping ~1.0 for table friction
- Angular damping ~0.8 for spin decay

### Control System
- Mouse-based aiming and power control
- Visual feedback through cue stick animation
- Power meter display during aiming
- Spin indicator for user feedback
- Debug visualization toggle

## Game States
1. **Aiming** - Player is positioning the cue stick
2. **Shooting** - Balls are in motion after a shot
3. **Waiting** - A pause after the cue ball is pocketed
4. **Game Over** - All numbered balls have been pocketed

## Technical Implementation Details

### Input Handling
- Mouse position tracking for aim direction
- Click-and-drag for power control
- Keyboard input for spin and game control
- Separate input handlers for each game state

### Rendering
- Layered rendering approach (table → balls → UI elements)
- Debug visualization options
- Simple color-based visual styling
- Dynamic positioning of game elements

### Collision Detection
- Custom collision callbacks for pocket detection
- User data for identifying colliding objects
- Simplified collision response for realistic physics

This technical demo prioritizes demonstrating LÖVE2D's physics capabilities while providing a functional pool game experience with minimal asset requirements.
