# Hacker News Client for LÖVE2D

A simple Hacker News client application built with the LÖVE2D framework. This client allows you to browse the top stories from Hacker News and view their comments.

## Features

- View a list of top stories from Hacker News
- View story details including title, author, score, and posting time
- Read comments for each story
- Open story links in your default web browser
- Auto-refresh stories list every 5 minutes

## Requirements

- LÖVE2D version 11.5
- LuaSocket (for HTTP requests)
- LuaSec (for HTTPS support)

## Installation

### Installing Dependencies

This client uses LuaSocket and LuaSec for network requests. You can install these dependencies using LuaRocks:

```bash
# Install LuaRocks if you don't have it
# Ubuntu/Debian: sudo apt install luarocks
# Arch Linux: sudo pacman -S luarocks
# macOS: brew install luarocks

# Install the dependencies
luarocks install luasocket --lua-version=5.1 --local
luarocks install luasec --lua-version=5.1 --local
```

### Running the Application

#### Method 1: Run Directly with Love2D

The application will try to find your locally installed LuaRocks modules:

```bash
love /path/to/009-hn-client
```

#### Method 2: Use Path Environment Variables

If Method 1 doesn't work, you can set the Lua path environment variables:

```bash
# Add LuaRocks modules to Lua's path
export LUA_PATH="$HOME/.luarocks/share/lua/5.1/?.lua;$HOME/.luarocks/share/lua/5.1/?/init.lua;;"
export LUA_CPATH="$HOME/.luarocks/lib/lua/5.1/?.so;;"

# Run the application
love /path/to/009-hn-client
```

#### Method 3: Use a Wrapper Script

Create a wrapper script called `run.sh`:

```bash
#!/bin/bash
# Set Lua paths for LuaRocks modules
export LUA_PATH="$HOME/.luarocks/share/lua/5.1/?.lua;$HOME/.luarocks/share/lua/5.1/?/init.lua;;"
export LUA_CPATH="$HOME/.luarocks/lib/lua/5.1/?.so;;"

# Run the application with Love2D
love .
```

Make it executable and run it:

```bash
chmod +x run.sh
./run.sh
```

## Troubleshooting

### LuaSocket/LuaSec Libraries Not Found

If you see the error "Warning: LuaSocket/LuaSec libraries not found. Using mock data.", try:

1. Check if the libraries are installed correctly:
   ```bash
   ls -la ~/.luarocks/lib/lua/5.1/
   ls -la ~/.luarocks/share/lua/5.1/
   ```

2. Try running with one of the methods described above that explicitly set the Lua paths.

3. If all else fails, the application will run in "Sample Data Mode" which uses mock data to demonstrate functionality.

## Controls

- **Left Mouse Button**: Select stories, press buttons
- **Mouse Wheel**: Scroll through content
- **Escape**: Go back from story detail to main list
- **Ctrl+R**: Refresh current view
- **F5**: Switch to mock data mode (if experiencing network issues)

## Project Structure

- `main.lua` - Main application entry point and state management
- `api.lua` - API interface for Hacker News
- `ui.lua` - UI components and rendering
- `utils.lua` - Utility functions for time formatting, text processing, etc.
- `https.lua` - HTTP request module using LuaSocket/LuaSec
- `conf.lua` - Application configuration

## Future Improvements

- Implement full comment threading
- Add user profiles and story submission
- Add search functionality
- Support for dark mode
- Offline caching of stories and comments
