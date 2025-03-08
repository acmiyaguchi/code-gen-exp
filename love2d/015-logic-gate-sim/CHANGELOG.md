# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-03-08

### Added
- Initial project structure and implementation
- Basic component framework (Gate, Wire, InputSwitch, OutputLED)
- Circuit class to manage all components and their interactions
- Implementation of logical gates (AND, OR, NOT, XOR)
- Basic drawing and rendering of all components
- User interaction via clicking on input switches
- Sample circuit demonstrating gate functionality:
  - AND gate receiving two inputs (A & B)
  - OR gate receiving one input (B) and the output of a NOT gate
  - NOT gate receiving one input (C)
- Configuration file for LÖVE2D
- Design document outlining the project architecture and goals
- TODO list identifying current issues (AND and NOT gates not functioning properly)

### Known Issues
- AND gate logic is not working correctly
- NOT gate is not properly propagating signals
