"**Create a Love2D-based, interactive coffee maker simulation.**

**Functionality:**

* **Carafe Visualization:**
    * Draw a visual representation of a coffee carafe using Love2D's drawing functions (e.g., `love.graphics.rectangle`, `love.graphics.polygon`).
    * Implement a mechanism to visually fill the carafe with a 'coffee' color as time progresses. This could be achieved by dynamically adjusting the height of a filled rectangle or similar method.
* **Drip Mechanism:**
    * Visually represent a drip mechanism above the carafe.
    * Simulate coffee dripping into the carafe using small, downward-moving graphical elements (e.g., small circles or rectangles).
    * Control the drip rate with the minute timer.
* **Minute Timer:**
    * Implement a minute timer that controls the drip rate and fill level.
    * Display the elapsed time using `love.graphics.print`.
    * Control the increase of the coffee level based on the timer.
* **Reset Button:**
    * Implement a clickable 'Reset' button using mouse input handling.
    * Clicking the 'Reset' button should:
        * Empty the carafe (reset the fill level).
        * Reset the timer to zero.
        * Restart the drip animation.
* **Technical Requirements:**
    * Use Love2D and Lua.
    * Prioritize smooth animations and a user-friendly interaction.
    * Code should be well commented.
* **Repository:**
    * Include a `README.md` file with:
        * A project description.
        * Instructions on how to run the simulation (including Love2D installation).
        * Any specific dependencies or configurations.
