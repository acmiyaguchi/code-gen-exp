# Chess Game Design Document (Love2D with miniKanren)

## 1. Introduction

This document outlines the design for a chess game built using Love2D and a Lua miniKanren library. The game will feature a basic AI opponent, a clean API for interacting with the game logic, and a modular structure for maintainability.  The design prioritizes clarity for developers with limited experience.

## 2. Goals

*   **Functional Chess Game:** Implement all standard chess rules.
*   **Clean API:** Provide a well-defined API for board and piece interaction.
*   **miniKanren Integration:** Use miniKanren for move validation and generation.
*   **Minimax AI:** Implement a basic AI using the minimax algorithm with alpha-beta pruning.
*   **Simple Heuristic:** Employ a straightforward scoring heuristic for the AI.
*   **Clear Code Structure:**  Prioritize readability and maintainability.
*   **Limited Dependencies:**  Only Love2D and a miniKanren library.

## 3. System Architecture

The game is divided into the following modules:

*   **`board.lua`:** Manages the chessboard state, piece positions, and basic move execution.
*   **`pieces.lua`:** Defines chess pieces and their movement rules (abstracted for miniKanren).
*   **`minikanren_interface.lua`:** Connects the game logic to the miniKanren library.
*   **`ai.lua`:** Implements the minimax AI and evaluation heuristic.
*   **`graphics.lua`:** Handles rendering the board, pieces, and UI.
*   **`input.lua`:** Manages user input (mouse clicks).
*   **`main.lua`:** The main game loop and initialization.
*   **`utils.lua`:**  Utility functions (e.g., coordinate conversions).

## 4. Module Details and API

### 4.1 `board.lua`

```lua
-- Represents a square on the board.
board.Square = {
    piece = nil,  -- The piece occupying the square (or nil).
    color = "",   -- "white" or "black" (square color).
}

-- Initializes a new board.
function board.new() ... end

-- Gets the piece at (row, col).
function board.get_piece(board_state, row, col) ... end

-- Moves a piece (assumes move is valid).
function board.move_piece(board_state, from_row, from_col, to_row, to_col) ... end

-- Checks for checkmate or stalemate.
function board.is_game_over(board_state) ... end

-- Returns the current player's turn ("white" or "black").
function board.current_turn(board_state) ... end

-- Creates a deep copy of the board state.
function board.deep_copy(board_state) ... end
```

### 4.2 `pieces.lua`

```lua
pieces.Piece = {
    type = "",    -- "pawn", "rook", etc.
    color = "",   -- "white" or "black"
    row = 0,
    col = 0,
}

-- Creates a new piece.
function pieces.new(piece_type, color, row, col) ... end

-- Registers a piece type and its move generation function (for miniKanren).
function pieces.register_piece_type(name, move_func) ... end

-- Get a registered peice type.
function pieces.get_piece_type(name) ... end
```

### 4.3 `minikanren_interface.lua`

```lua
-- Converts the board state to a miniKanren-compatible format.
function minikanren_interface.board_to_kanren(board_state) ... end

-- Converts a miniKanren result to a (row, col) move.
function minikanren_interface.kanren_to_move(kanren_result) ... end

-- Gets all valid moves for a piece using miniKanren.
function minikanren_interface.get_valid_moves(board_state, piece) ... end

-- Checks if a specific move is valid using miniKanren.
function minikanren_interface.is_valid_move(board_state, from_row, from_col, to_row, to_col) ... end
```

### 4.4 `ai.lua`

```lua
-- Chooses the best move using minimax.
function ai.choose_move(board_state, depth) ... end

-- The minimax algorithm with alpha-beta pruning.
function ai.minimax(board_state, depth, alpha, beta, maximizing_player) ... end

-- The evaluation heuristic (scores board positions).
function ai.evaluate_board(board_state) ... end
```

### 4.5 `graphics.lua`

```lua
-- Draws the board and pieces.
function graphics.draw_board(board_state) ... end

-- Draws a specific peice.
function graphics.draw_piece(piece) ... end

-- Updates the graphics.
function graphics.update(board_state) ... end

-- Draws highlighted squares.
function graphics.draw_highlights(highlighted_squares) ... end
```

### 4.6 `input.lua`

```lua
-- Handles mouse clicks for piece selection and movement.
function input.handle_mouse_click(x, y, board_state) ... end

-- Handles keyboard input (optional).
function input.handle_key_press(key) ... end
```

### 4.7 `main.lua`

```lua
-- Initializes the game.
function love.load() ... end

-- The main game loop.
function love.update(dt) ... end

-- Draws everything.
function love.draw() ... end

-- Handles mouse clicks
function love.mousepressed(x, y, button, istouch, presses) ... end
```
### 4.8 `utils.lua`
```lua
    -- Converts a row and column (1-8) to pixel coordinates for drawing.
    function utils.grid_to_pixels(row, col) ... end

    -- Converts pixel coordinates to a row and column (1-8).
    function utils.pixels_to_grid(x, y) ... end
```

## 5. miniKanren Integration

*   `pieces.register_piece_type` connects each piece type to a miniKanren move generation function.
*   `minikanren_interface.lua` translates between the game's board representation and miniKanren's format.
*   miniKanren *generates* all legal moves for a piece, rather than just validating them.

## 6. AI (Minimax)

*   `ai.choose_move` is the entry point for the AI.
*   `ai.minimax` recursively explores the game tree, using alpha-beta pruning for optimization.
*   `ai.evaluate_board` uses a heuristic to score board positions.  A simple heuristic might consider:
    *   Material difference (piece values).
    *   Control of the center.
    *   Checkmate/being checkmated.

## 7. Data Structures

*   **Board:** 2D array (8x8) of `board.Square` objects.
*   **Piece:** Object with `type`, `color`, `row`, and `col`.
*   **Move:** Table: `{from_row, from_col, to_row, to_col}`.
*   **List of Moves:** Table of moves.

## 8. Further Considerations

*   **Error Handling:**  Implement robust error checking.
*   **Game State Management:**  Handle castling, en passant, and the fifty-move rule.
*   **User Interface:**  Design UI elements (buttons, captured piece display).
*   **Testing:**  Thoroughly test game rules and AI (unit and integration tests).
