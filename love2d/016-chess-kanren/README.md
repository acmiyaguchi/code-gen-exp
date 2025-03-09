# Chess Kanren

A chess implementation built with LÖVE2D, featuring standard chess rules and a clean interface.

![Chess Game Screenshot](screenshot.png)

## Description

Chess Kanren is a digital chess game that implements traditional chess rules. The game provides a clean interface with a classic wooden board design, piece movement validation, check/checkmate detection, and display of captured pieces.

## Features

- Standard chess board and piece representation
- Legal move validation for all pieces
- Turn-based gameplay (white starts)
- Highlighting of selected pieces and legal moves
- Check and checkmate detection
- Display of captured pieces
- Clean, readable interface with algebraic notation

## Requirements

- [LÖVE2D](https://love2d.org/) (version 11.4 or later recommended)

## Installation

1. Install LÖVE2D from [https://love2d.org/](https://love2d.org/)
2. Clone this repository:
   ```
   git clone https://github.com/yourusername/chess-kanren.git
   cd chess-kanren
   ```
3. Run the game:
   ```
   love .
   ```

## How to Play

- Click on a piece to select it
- Valid moves will be highlighted on the board
- Click on a highlighted square to move the selected piece
- The game enforces all standard chess rules including:
  - Piece movement restrictions
  - Check and checkmate
  - Castling
  - En passant
  - Pawn promotion

## Controls

- **Left Mouse Button**: Select pieces and make moves
- **ESC**: Exit the game

## Project Structure

- `main.lua` - Entry point for the LÖVE2D application
- `board.lua` - Chess board logic and state management
- `graphics.lua` - Rendering code for the board and pieces
- `moves.lua` - Move generation and validation
- `utils.lua` - Helper functions
- `assets/` - Game assets including piece images

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Chess piece assets by [Creator Name] licensed under [License]
- LÖVE2D framework by [rude](https://github.com/rude) and contributors