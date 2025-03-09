# Changelog
All notable changes to the Chess Kanren project will be documented in this file.

## [Unreleased]
- Fix stalemate detection which currently triggers incorrectly
- Enhance miniKanren integration for more complex chess patterns
- Improve AI decision making with deeper search

## [0.3.0]
### Added
- Complete miniKanren-based move validation for all pieces
- Check and checkmate detection using constraint logic
- Castling, en passant, and pawn promotion rules
- Integration of miniKanren in AI evaluation system

### Changed
- Refactored piece movement to use declarative constraints
- Enhanced board representation to track game state
- Improved move validation by detecting checks

### Fixed
- AI timer implementation using delta time
- Board coordinate system and piece selection

### Known Issues
- Stalemate detection triggers incorrectly, causing games to end prematurely
- Some edge cases in check detection need refinement

## [0.2.0]
### Added
- Proper piece movement validation for all chess pieces
- Basic AI implementation
- Board highlighting for valid moves
- Move validation using miniKanren framework
- Timer-based AI move delay

### Changed
- Refactored board representation for better integration with miniKanren
- Improved move validation system
- Simplified piece movement rules

## [0.1.0]
### Added
- Basic chess board rendering
- Piece movement according to standard chess rules
- Turn-based gameplay
- Check and checkmate detection
- Captured pieces display
- Visual highlights for selected pieces and valid moves
- Algebraic notation for squares (A1-H8)

### Technical
- LÖVE2D framework for graphics and input handling
- Custom chess logic implementation