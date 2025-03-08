# Othello Interactive Reader - Design Document

## Overview
The Othello Interactive Reader is a Love2D application that presents Shakespeare's play "Othello" in a modern, interactive format. It parses a Project Gutenberg text file and displays the content in a visually appealing and easily navigable interface.

## Features

### 1. Navigation System
- **Menu Mode**: A hierarchical menu showing all acts and scenes
- **Reading Mode**: Text display with navigation controls
- **Navigation Controls**:
  - Next/Previous scene buttons
  - Return to menu button
  - Keyboard shortcuts (arrow keys, page up/down)
  - Mouse wheel for scrolling

### 2. Visual Design
- **Background**: Subtle animated shader background using Perlin noise
- **Text Bubbles**: Text is organized into digestible "bubbles" with rounded corners
- **Color Scheme**: Dark theme with readable text and subtle highlights
- **Typography**: Clear hierarchical font sizing for different text elements

### 3. Parsing Logic
- Parse Project Gutenberg text file of Othello
- Identify act and scene structure
- Process text into logical chunks for display
- Handle stage directions and character names

## Technical Architecture

### Main Components
1. **main.lua**: Application entry point and state management
2. **ui.lua**: Common UI elements and utility functions
3. **menu.lua**: Menu interface implementation
4. **reader.lua**: Reading view implementation
5. **parser.lua**: Text processing functions
6. **shaders/background.glsl**: Procedural background shader

### Data Flow
1. The application loads and parses the text file on startup
2. The user navigates via the menu to select an act and scene
3. The reader component displays the selected content
4. Navigation controls allow moving between scenes or returning to the menu

### State Management
The application maintains a global state object containing:
- Current mode (menu or reader)
- Parsed play data
- Current act and scene selection

## User Experience

### Menu Mode
- Display title, author, and instructions
- Show collapsible/expandable list of acts
- Each act can reveal its scenes when clicked
- Clicking a scene transitions to reading that scene

### Reading Mode
- Text is displayed in rounded bubble containers
- Navigation bar at top with prev/next/menu buttons
- Smooth scrolling for reading longer scenes
- Displays current act and scene information

## Visual Style
- **Colors**: Dark blues and purples for background with white text
- **UI Elements**: Rounded corners for all interactive elements
- **Animation**: Subtle background animation for visual interest
- **Layout**: Centered, readable text with appropriate margins

## Implementation Notes
- Text parsing needs to handle Project Gutenberg's specific formatting
- Bubble creation should balance readability with coherent content chunks
- Memory usage should be optimized for mobile devices
- All interfaces should be keyboard-navigable for accessibility
