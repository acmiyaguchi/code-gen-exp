# Infinite Starfield in LÖVE2D

This project demonstrates an infinite scrolling starfield effect implemented in LÖVE2D (Love2D). It creates the illusion of traveling through space by using repeating star patterns with deterministic randomization.

## Features

- Infinite scrolling in any direction
- Smooth zooming in and out
- Optimized drawing within the viewport
- Deterministic star generation ensuring consistent patterns

## Controls

- Arrow keys: Move the viewport
- `+` key: Zoom in
- `-` key: Zoom out
- `ESC`: Quit the application

## How It Works

The starfield uses a clever technique to create the illusion of an infinite star pattern:

1. A base pattern of stars is generated in a finite area
2. This pattern is repeated in a grid to cover the visible viewport
3. Each repeated cell has a slight random offset based on its grid position
4. As the viewport moves, new grid cells are drawn while out-of-view cells are skipped

This approach uses much less memory than generating a truly "infinite" field of stars, while maintaining the illusion of endless unique stars.

## Implementation Notes

The StarField module has the following key components:

- `StarField.new(density)`: Creates a new starfield with the specified star density
- `StarField:draw(viewport)`: Renders the starfield according to the current viewport position and scale
- Internal deterministic randomization to ensure consistent star placement

## Reference

This implementation is based on the JavaScript starfield from:
- https://github.com/rfotino/space-ai/blob/master/src%2Fobj%2FStarField.js

## Dependencies

- LÖVE2D (tested with version 11.x)
