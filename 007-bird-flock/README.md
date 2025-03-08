# Flocking Birds Simulation

This project is a Love2D simulation of a flock of birds exhibiting flocking behavior based on the Boids algorithm. Each bird follows three primary rules:

1. **Separation**: Steer to avoid crowding local flockmates. Birds maintain a minimum distance from each other.
2. **Alignment**: Steer towards the average heading of local flockmates. Birds try to match the direction and speed of nearby birds.
3. **Cohesion**: Steer to move towards the average position (center of mass) of local flockmates. Birds try to stay close to the group.

## Features

- Visual representation of birds as circles.
- Birds wrap around the screen edges; when a bird goes off one edge, it reappears on the opposite edge.
- Adjustable parameters to control the strength of the separation, alignment, and cohesion forces, as well as the birds' maximum speed and perception radius.
- Timer to track the duration of the simulation.
- Ability to restart the simulation by pressing the "r" key.

## Parameters

The behavior of the flock can be adjusted through the following parameters:

- `separationRadius`: The distance within which birds consider other birds for separation.
- `alignmentRadius`: The distance within which birds consider other birds for alignment.
- `cohesionRadius`: The distance within which birds consider other birds for cohesion.
- `separationWeight`: The strength of the separation force.
- `alignmentWeight`: The strength of the alignment force.
- `cohesionWeight`: The strength of the cohesion force.
- `maxSpeed`: The maximum speed of the birds.

## Controls

- Press `r` to restart the simulation.

## Installation

1. Ensure you have [Love2D](https://love2d.org/) installed on your system.
2. Clone this repository to your local machine.

## Running the Simulation

1. Navigate to the project directory.
2. Run the simulation using Love2D:
   ```sh
   love .
   ```

## File Structure

- `main.lua`: The main script containing the implementation of the Boids algorithm and the Love2D callbacks.
- `README.md`: This file, providing an overview of the project.

## Prompts

Prompts were generated using gemini advanced, and then fed into gpt-4o via copilot.