# Fractal Viewer

A simple Mandelbrot set fractal viewer built with LÖVE (Love2D). This application lets you explore the fascinating world of fractals through an interactive interface with zoom and pan controls.

## Features

- Renders the Mandelbrot set fractal in real-time
- Smooth color mapping for visually appealing results
- Interactive controls:
  - Zoom in/out with the mouse wheel
  - Pan by clicking and dragging
  - Reset view with the 'R' key
- On-screen information display showing current scale and position

## Requirements

- LÖVE (Love2D) 11.0 or newer. Download from [https://love2d.org/](https://love2d.org/)

## How to Run

1. Install LÖVE from the official website if you haven't already
2. Clone this repository
3. Run the application using one of these methods:
   - Drag the folder onto the LÖVE executable
   - From command line: `love /path/to/014-fractal`

## Controls

- **Mouse wheel**: Zoom in and out, centered on the mouse cursor
- **Click and drag**: Pan around the fractal
- **R key**: Reset to the default view

## Understanding the Mandelbrot Set

The Mandelbrot set is a famous fractal defined by a simple iterative function in the complex plane. For each point c = x + yi:
1. Start with z = 0
2. Repeatedly compute z = z² + c
3. If the magnitude of z stays bounded (doesn't escape to infinity) after many iterations, the point is in the set

The colors represent how quickly the points outside the set "escape" to infinity, revealing the complex boundary of the fractal.

## Customization

You can modify these parameters in the `config` table at the top of `main.lua`:

- `maxIterations`: Higher values give more detail but reduce performance
- `escapeRadius`: Threshold for determining if a point escapes
- `zoomSpeed`: Controls how fast zooming occurs
- `colorCycles`: Adjusts the frequency of color cycling

## Interesting Locations to Explore

Try navigating to these coordinates to see interesting formations:
- `-0.75, 0.0` (Main bulb)
- `-0.123, 0.745` (Embedded Julia set)
- `-1.94, 0.0` (Period-2 bulb)
- `-0.16, 1.0375` (Satellite spiral)

## License

This project is released under the MIT License. Feel free to use, modify, and distribute it as you like.
