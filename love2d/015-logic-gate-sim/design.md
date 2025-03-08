# Design Document: Simple Digital Circuit Simulator in LÖVE2D

## 1. Introduction

This document outlines the design and development of a basic digital circuit simulator using the LÖVE2D game framework.  The goal is to create a visually appealing and interactive demonstration of a very simple circuit, illustrating fundamental logic gate behavior. This simulator is intended as a proof-of-concept and educational tool, not a full-fledged circuit design application.  Emphasis is placed on visual clarity and ease of understanding.

## 2. Goals

*   **Functionality:** Simulate a basic digital circuit with AND, OR, NOT, and XOR gates.
*   **Interactivity:** Allow users to toggle input switches and observe the resulting output changes.
*   **Visualization:** Clearly represent circuit components (gates, wires, inputs, outputs) with distinct visual states (on/off).
*   **Performance:** Maintain a smooth frame rate even with moderate circuit complexity.
*   **Extensibility:** Design the code in a way that allows for easier addition of new components and features in the future.
*   **Educational Value:** Provide a clear and intuitive demonstration of basic digital logic.

## 3. Target Audience

This project is aimed at individuals learning about digital circuits, students in introductory computer science or electronics courses, and anyone interested in seeing a visual representation of basic logic gates.

## 4. System Architecture

The simulator will be built using LÖVE2D and Lua. It will follow a component-based architecture.  The core components will be:

*   **Gate:** An abstract base class representing a generic logic gate.  Subclasses (ANDGate, ORGate, NOTGate, XORGate) will implement specific gate logic.
*   **Wire:**  Connects gates and components, carrying signals (true/false).
*   **InputSwitch:** A user-controllable input source (toggle switch).
*   **OutputLED:** A visual indicator representing the output of the circuit (lit/unlit).
*   **Circuit:** The main container holding all components and managing the simulation logic (propagation of signals).
*   **Renderer:** Handles drawing all the components to the screen.
*   **InputHandler:**  Processes mouse clicks and interactions.

## 5. Detailed Component Design

### 5.1 Gate

*   **Properties:**
    *   `inputs`: A table (array) of Wires connected to the gate's inputs.
    *   `output`: A Wire representing the gate's output.
    *   `x`, `y`:  Screen coordinates of the gate's position.
    *   `type`:  String identifier ("AND", "OR", "NOT", "XOR").
    *   `logicFunction`: A function that implements the gate's truth table.
*   **Methods:**
    *   `update()`:  Calculates the gate's output based on its inputs and `logicFunction`.
    *   `draw()`:  Draws the gate's graphical representation (using LÖVE2D's drawing functions).
    *   `connectInput(wire, index)`: Connects a wire to a specific input index.
    * `connectOutput(wire)`: connects the output wire.

### 5.2 Wire

*   **Properties:**
    *   `state`: Boolean value representing the signal carried by the wire (true = HIGH, false = LOW).
    *   `source`: The Gate or InputSwitch the wire originates from.
    *   `destination`: The Gate or OutputLED the wire connects to.
    *   `sourceX`, `sourceY`, `destinationX`, `destinationY`: Coordinates for drawing the wire.  These will be derived from the connected components' positions.
*   **Methods:**
    *   `setState(newState)`: Updates the wire's state and propagates the change to the destination.
    *   `draw()`: Draws the wire as a line (or series of line segments) with a color indicating its state.
    * `getSourceCoordinates()`
    * `getDestinationCoordinates()`

### 5.3 InputSwitch

*   **Properties:**
    *   `state`: Boolean value (true = ON, false = OFF).
    *   `output`:  A Wire carrying the switch's state.
    *   `x`, `y`:  Screen coordinates.
*   **Methods:**
    *   `toggle()`:  Changes the switch's state.
    *   `draw()`:  Draws the switch (e.g., a toggle switch graphic).
    *   `connectOutput(wire)`: Connects the output wire.
    *   `isClicked(mouseX, mouseY)`:  Checks if the mouse click coordinates are within the switch's bounds.

### 5.4 OutputLED

*   **Properties:**
    *   `input`:  A Wire connected to the LED.
    *   `x`, `y`: Screen coordinates.
    *   `state`:  Boolean (derived from the input wire).
*   **Methods:**
    *   `draw()`: Draws the LED (e.g., a circle with different colors for on/off states).
    * `connectInput(wire)`

### 5.5 Circuit

*   **Properties:**
    *   `components`:  A table containing all Gates, InputSwitches, OutputLEDs, and Wires in the circuit.
*   **Methods:**
    *   `add(component)`: Adds a component to the circuit.
    *   `update()`:  Iterates through all components and updates their states (in a topological order to ensure correct signal propagation). This will likely involve multiple passes until a stable state is reached.
    *   `draw()`: Calls the `draw()` method of each component.
    *   `handleClick(x, y)`:  Handles mouse clicks, checking for interactions with InputSwitches.
    * `clear()`: Resets the circuit.

### 5.6 Renderer

*   **Properties:**
     * None (stateless)
*   **Methods:**
    * `drawWire(wire)`
    * `drawGate(gate)`
    * `drawSwitch(switch)`
    * `drawLED(led)`

### 5.7 InputHandler
*   **Properties:**
     * None (stateless)
*   **Methods:**
    *   `handleMouseClick(x, y, button)`:  Processes mouse click events and relays them to the `Circuit`.

## 6. User Interface

The user interface will be simple and intuitive:

*   **Circuit Display:** The main area will display the circuit components and connections.
*   **Input Switches:**  Clearly labeled toggle switches will be used to control inputs.
*   **Output LEDs:**  LEDs will visually indicate the output states.

No additional UI elements (menus, toolbars) are planned for this basic demo.

## 7. Implementation Details

*   **LÖVE2D Callbacks:** The project will utilize LÖVE2D's standard callbacks:
    *   `love.load()`:  Initialize the circuit, components, and renderer.
    *   `love.update(dt)`: Update the circuit's state (propagate signals) based on the delta time (`dt`).
    *   `love.draw()`:  Draw the circuit components.
    *   `love.mousepressed(x, y, button, istouch, presses)`: Handle mouse clicks for interacting with input switches.
*   **Signal Propagation:**  The `Circuit.update()` method will handle signal propagation.  A simple iterative approach will be used:
    1.  Update all InputSwitches.
    2.  Update all Wires based on their source components' states.
    3.  Update all Gates based on their input Wires' states.
    4.  Update all OutputLEDs based on their input Wires.
    5.  Repeat steps 2-4 until no component's state changes (convergence).  This handles feedback loops.  A maximum iteration count will be implemented to prevent infinite loops in case of oscillatory circuits.
*   **Drawing:**  LÖVE2D's `love.graphics` module will be used for drawing.  Simple shapes (rectangles, circles, lines) will represent the components. Different colors will indicate on/off states.

## 8. Example Circuit

The initial demo circuit will be a simple combination of gates, such as:

```
Input A --\
           |--- AND Gate --- Output X
Input B --/
           |--- OR Gate --- Output Y
Input C --/--- NOT Gate ---/
```

This will demonstrate the basic functionality of each gate type and how they interact.

## 9. Future Enhancements (Beyond Scope of Initial Demo)

*   **More Components:**  Add more gate types (NAND, NOR, etc.), flip-flops, and other digital components.
*   **User-Defined Circuits:** Allow users to create and connect components interactively.
*   **Saving/Loading Circuits:**  Implement functionality to save and load circuit designs.
*   **Clock Signal:** Introduce a clock signal for simulating sequential circuits.
*   **Sub-Circuits:** Allow grouping of components into reusable sub-circuits.
* **Improved UI**

## 10.  Risks and Challenges

*   **Signal Propagation Complexity:** Ensuring correct and efficient signal propagation, especially in circuits with feedback loops, can be challenging. The iterative approach needs careful implementation to avoid infinite loops and ensure accurate results.
*   **Performance Optimization:** Complex circuits might lead to performance issues.  Optimizing the update and drawing routines will be crucial.
*   **User Interface Scalability:** The current design focuses on a very simple circuit.  Expanding the UI to support more complex circuits will require significant additions.

## 11. Testing

*   **Unit Tests:**  Individual components (Gates, Wires) will be tested with unit tests to verify their logic and behavior.
*   **Integration Tests:**  Small circuits will be constructed and tested to ensure components interact correctly.
*   **Visual Inspection:** The simulator's output will be visually inspected to confirm that the circuit behaves as expected.
*   **User Testing:** Basic user testing to ensure ease of use.

## 12. Code Style

Consistent code style (indentation, naming conventions) will be used throughout the project to improve readability and maintainability. Lua style guide (e.g. the one from Olivine Labs) will be generally followed.

## 13. Dependencies

*   LÖVE2D (version 11.x or later)

This design document provides a solid foundation for developing the basic digital circuit simulator. The component-based architecture and clear separation of concerns should make the project manageable and extensible.

