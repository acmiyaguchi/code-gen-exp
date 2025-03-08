
# Star Display Program

This program is written in Lua using the LÖVE 2D game framework. It displays a large star in the center of the screen and a number of smaller stars scattered around it. Each star rotates at a different speed, creating a dynamic and visually appealing effect.

## Features

- A large star positioned at the center of the screen.
- 100 smaller stars randomly positioned around the screen.
- Each star rotates at a different speed.
- Stars are drawn with a customizable number of points and inner ratio.

## How to Run

1. Ensure you have LÖVE 2D installed on your system. You can download it from [https://love2d.org/](https://love2d.org/).
2. Place the `main.lua` file and this `README.md` file in a directory.
3. Open a terminal and navigate to the directory containing the files.
4. Run the program using the command:
   ```
   love .
   ```

## Code Overview

- `love.load()`: Initializes the stars with random positions, sizes, speeds, and angles.
- `love.update(dt)`: Updates the angles of the stars based on their rotation speeds.
- `love.draw()`: Draws the big star and the smaller stars on the screen.
- `drawStar(x, y, size, angle, points, innerRatio, mode, color)`: Draws a star at the specified position with the given parameters.
- `starVertices(size, points, innerRatio)`: Calculates the vertices of a star based on its size, number of points, and inner ratio.

## Customization

You can customize the appearance and behavior of the stars by modifying the parameters in the `drawStar` and `starVertices` functions. For example, you can change the number of points, the inner ratio, the rotation speed, and the colors of the stars.

Enjoy experimenting with the star display program!
